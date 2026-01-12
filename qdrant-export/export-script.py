#!/usr/bin/env python3
"""
Export Qdrant collections → Markdown files
Production-ready, simple, robust
"""

import os
import sys
import json
import logging
from pathlib import Path
from datetime import datetime
from typing import Dict, Optional

from qdrant_client import QdrantClient
import frontmatter

# Configuration depuis variables d'environnement
QDRANT_URL = os.getenv("QDRANT_URL", "http://qdrant:6333")
EXPORT_DIR = Path(os.getenv("EXPORT_DIR", "/mnt/export"))
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")
EXPORT_MODE = os.getenv("EXPORT_MODE", "normal")  # normal ou dry-run
CLEANUP_ORPHANED = os.getenv("CLEANUP_ORPHANED", "false").lower() == "true"

# Setup logging directory
log_dir = Path("/app/data")
log_file = log_dir / 'export.log'

# Try to create log directory and file, fallback to stdout only if permission denied
handlers = [logging.StreamHandler(sys.stdout)]
try:
    log_dir.mkdir(parents=True, exist_ok=True)
    handlers.append(logging.FileHandler(log_file))
except (PermissionError, OSError) as e:
    # If we can't write to /app/data, just use stdout (will be captured by Docker logs)
    pass

# Setup logging
logging.basicConfig(
    level=getattr(logging, LOG_LEVEL),
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=handlers
)
logger = logging.getLogger(__name__)


class QdrantExporter:
    """Export Qdrant collections to Markdown files"""
    
    def __init__(self, qdrant_url: str, output_dir: Path):
        self.client = QdrantClient(url=qdrant_url)
        self.output_dir = output_dir
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.stats = {
            "collections": 0,
            "documents": 0,
            "errors": 0,
            "start_time": datetime.now().isoformat()
        }
    
    def export_all(self) -> Dict:
        """Export all collections from Qdrant"""
        try:
            collections = self.client.get_collections()
            logger.info(f"Found {len(collections.collections)} collections")
            
            # Track exported files for cleanup
            exported_files = set()
            
            for collection in collections.collections:
                collection_files = self._export_collection(collection.name)
                exported_files.update(collection_files)
            
            # Cleanup orphaned files if enabled
            if CLEANUP_ORPHANED:
                self._cleanup_orphaned_files(exported_files)
            
            duration = (datetime.now() - datetime.fromisoformat(self.stats["start_time"])).total_seconds()
            logger.info(
                f"✅ Export complete: {self.stats['collections']} collections, "
                f"{self.stats['documents']} documents in {duration:.1f}s"
            )
            
            return self.stats
            
        except Exception as e:
            logger.error(f"❌ Export failed: {e}", exc_info=True)
            self.stats["errors"] += 1
            raise
    
    def _export_collection(self, collection_name: str) -> set:
        """Export a single collection, returns set of exported file paths"""
        collection_dir = self.output_dir / collection_name
        collection_dir.mkdir(parents=True, exist_ok=True)
        
        logger.info(f"Exporting collection: {collection_name}")
        exported_files = set()
        
        try:
            # Scroll through all points
            points = []
            offset = None
            
            while True:
                result = self.client.scroll(
                    collection_name=collection_name,
                    limit=100,
                    offset=offset,
                    with_payload=True,
                    with_vectors=False
                )
                
                batch_points, next_offset = result
                points.extend(batch_points)
                
                if next_offset is None:
                    break
                offset = next_offset
            
            # Export each point as Markdown file
            exported = 0
            for point in points:
                try:
                    filepath = self._export_point(point, collection_dir, collection_name)
                    if filepath:
                        exported_files.add(filepath)
                        exported += 1
                except Exception as e:
                    logger.warning(f"Failed to export point {point.id}: {e}")
                    self.stats["errors"] += 1
            
            logger.info(f"  {collection_name}: {exported}/{len(points)} documents")
            self.stats["collections"] += 1
            self.stats["documents"] += exported
            
            return exported_files
            
        except Exception as e:
            logger.error(f"Failed to export collection {collection_name}: {e}")
            self.stats["errors"] += 1
            return set()
    
    def _export_point(self, point, output_dir: Path, collection_name: str) -> Optional[Path]:
        """Export a single Qdrant point to Markdown file (idempotent)"""
        payload = point.payload or {}
        
        # Extract content - support multiple payload structures:
        # - content/text (open-webui)
        # - document (cursor-context, cursor-knowledge, loa-hf)
        # - metadata.document (nested structure)
        content = (
            payload.get("content") or 
            payload.get("text") or 
            payload.get("document") or
            (payload.get("metadata", {}) or {}).get("document") or
            (payload.get("metadata", {}) or {}).get("content") or
            (payload.get("metadata", {}) or {}).get("text") or
            ""
        )
        
        # Handle case where document might be a dict with content
        if isinstance(content, dict):
            content = content.get("content") or content.get("text") or str(content)
        
        if not content or (isinstance(content, str) and not content.strip()):
            logger.debug(f"Skipping point {point.id}: no content")
            return None
        
        # Generate filename from title or ID
        title = payload.get("title", f"doc-{point.id}")
        safe_filename = "".join(
            c for c in title if c.isalnum() or c in " -_"
        ).strip()[:100]  # Limit length
        
        if not safe_filename:
            safe_filename = f"doc-{point.id}"
        
        # Create frontmatter
        metadata = {
            "id": str(point.id),
            "collection": collection_name,
            "title": title,
            "exported_at": datetime.now().isoformat(),
        }
        
        # Add optional metadata
        if "created_at" in payload:
            metadata["created_at"] = payload["created_at"]
        if "tags" in payload:
            metadata["tags"] = payload["tags"]
        if "source" in payload:
            metadata["source"] = payload["source"]
        if "metadata" in payload and isinstance(payload["metadata"], dict):
            # Add nested metadata if present
            nested_meta = payload["metadata"]
            for key in ["type", "date", "source"]:
                if key in nested_meta:
                    metadata[f"meta_{key}"] = nested_meta[key]
        
        # Create Markdown file
        post = frontmatter.Post(content, **metadata)
        filepath = output_dir / f"{safe_filename}.md"
        
        # Dry-run mode: just log, don't write
        if EXPORT_MODE == "dry-run":
            logger.info(f"[DRY-RUN] Would export: {filepath}")
            return filepath
        
        # Idempotent: overwrite existing file (Qdrant ID is unique)
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(frontmatter.dumps(post))
        
        logger.debug(f"Exported: {filepath.name}")
        return filepath
    
    
    def _cleanup_orphaned_files(self, exported_files: set):
        """Remove Markdown files that no longer exist in Qdrant"""
        logger.info("Cleaning up orphaned files...")
        removed = 0
        
        # Convert exported_files to set of Path objects for comparison
        exported_paths = {Path(f) if isinstance(f, str) else f for f in exported_files}
        
        for collection_dir in self.output_dir.iterdir():
            if not collection_dir.is_dir():
                continue
            
            for md_file in collection_dir.glob("*.md"):
                # Compare absolute paths
                if md_file.resolve() not in {p.resolve() for p in exported_paths}:
                    logger.info(f"Removing orphaned file: {md_file}")
                    try:
                        md_file.unlink()
                        removed += 1
                    except Exception as e:
                        logger.warning(f"Failed to remove {md_file}: {e}")
        
        logger.info(f"Cleaned up {removed} orphaned files")
        self.stats["orphaned_removed"] = removed


def main():
    """Main entry point"""
    logger.info("🚀 Starting Qdrant export")
    
    try:
        exporter = QdrantExporter(QDRANT_URL, EXPORT_DIR)
        stats = exporter.export_all()
        
        # Write stats to JSON file (if we have write permissions)
        stats_file = Path("/app/data/export-stats.json")
        stats["end_time"] = datetime.now().isoformat()
        try:
            with open(stats_file, "w") as f:
                json.dump(stats, f, indent=2)
        except (PermissionError, OSError) as e:
            logger.warning(f"Could not write stats file: {e} (stats available in logs)")
        
        sys.exit(0 if stats["errors"] == 0 else 1)
        
    except Exception as e:
        logger.error(f"Fatal error: {e}", exc_info=True)
        sys.exit(1)


if __name__ == "__main__":
    main()

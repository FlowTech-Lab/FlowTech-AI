---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:33.488563'
id: e8e8b457-d90f-4916-aba0-ac70f9acd8be
title: doc-e8e8b457-d90f-4916-aba0-ac70f9acd8be
---

created$ cat vm.yamlapiVersion: kubevirt.io/v1alpha3kind: VirtualMachinemetadata:  name: testvmspec:  running: false  template:    metadata:      labels:         kubevirt.io/size: small        kubevirt.io/domain: testvm    spec:      domain:        devices:          disks:          - disk:              bus: virtio            name: rootfs          - disk:              bus: virtio            name: cloudinit          interfaces:          - name: default            masquerade: {}        resources:          requests:            memory: 64M      networks:      - name: default        pod: {}      volumes:        - name: rootfs          containerDisk:            image: kubevirt/cirros-registry-disk-demo        - name: cloudinit          cloudInitNoCloud:            userDataBase64: SGkuXG4= $ kubectl describe vm testvmName:         testvmNamespace:    defaultLabels:       <none>Annotations:  kubevirt.io/latest-observed-api-version: v1              kubevirt.io/storage-observed-api-version:
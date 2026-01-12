---
collection: cursor-context
exported_at: '2026-01-11T22:30:22.019569'
id: 9700cec3-00ef-4bb4-8d8e-61de3a8cf94b
title: doc-9700cec3-00ef-4bb4-8d8e-61de3a8cf94b
---

Guide d'Apprentissage JavaScript - Conditions et Boucles

## Conditions

```javascript
let temperature = 25;

if (temperature > 30) {
    console.log("Il fait chaud !");
} else if (temperature > 20) {
    console.log("Il fait bon !");
} else {
    console.log("Il fait frais !");
}
```

### Opérateurs de comparaison
```javascript
let x = 5;
let y = "5";

console.log(x == y);   // true (égalité de contenu)
console.log(x === y);  // false (égalité de contenu ET type)
console.log(x != y);   // false (différence de contenu)
console.log(x !== y);  // true (différence de contenu OU type)
```

## Boucles

### Boucle for
```javascript
for (let i = 1; i <= 5; i++) {
    console.log(`Compteur : ${i}`);
}
```

### Boucle for...in (objets)
```javascript
for (let cle in personne) {
    console.log(`${cle}: ${personne[cle]}`);
}
```

### Boucle for...of (arrays)
```javascript
for (let fruit of fruits) {
    console.log(fruit);
}
```

## Fonctions

### Fonction classique
```javascript
function direBonjour(nom) {
    return `Bonjour ${nom} !`;
}

console.log(direBonjour("Alice")); // "Bonjour Alice !"
```

### Fonction fléchée (Arrow Function)
```javascript
const additionner = (a, b) => a + b;
console.log(additionner(3, 4)); // 7
```

### Fonction anonyme
```javascript
const multiplier = function(x, y) {
    return x * y;
};
console.log(multiplier(5, 6)); // 30
```
import { writable, derived } from "svelte/store";

export const pets = writable([
    { id: 1, name: 'dog', votes: 0, url: 'images/dog.jpg' },
    { id: 2, name: 'cat', votes: 0, url: 'images/cat.jpg' },
    { id: 3, name: 'bird', votes: 0, url: 'images/bird.jpg' },
]);
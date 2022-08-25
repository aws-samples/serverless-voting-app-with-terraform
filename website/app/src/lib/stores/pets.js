import { browser } from "$app/env";
import { writable, derived } from "svelte/store";

export const pets = writable([
    { id: 'dog', votes: 0, img_url: 'images/dog.jpg', order: 1 },
    { id: 'cat', votes: 0, img_url: 'images/cat.jpg', order: 2 },
    { id: 'bird', votes: 0, img_url: 'images/bird.jpg', order: 3 },
]);

export async function load_votes() {
    console.log('load votes from voting-api')
    const apigw_endpoint = JSON.parse(localStorage.getItem("options")).apigw_endpoint

    const res = await fetch(apigw_endpoint + '/votes')
    console.log(res)
    if (res.ok) {
        const data = await res.json()
        const votes = data.map(vote => { return { id: vote.PK, votes: vote.votes, img_url: vote.img_url } })
        console.log(`votes=${JSON.stringify(votes)}`)
        pets.set(votes)
    } else {
        console.error(`failed to fetch votes from api: ${apigw_endpoint}`)
    }
}

export async function save_vote(vote) {
    console.log(`send vote to voting-api: ${JSON.stringify(vote)}`)
    const apigw_endpoint = JSON.parse(localStorage.getItem("options")).apigw_endpoint

    const res = await fetch(apigw_endpoint + '/votes', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ id: vote.id, img_url: vote.img_url }),
    }
    )
    const data = await res.json()
    return data
}

export const options = writable(browser && JSON.parse(localStorage.getItem("options")) || {})

if (browser) {

    options.subscribe((value) => {
        console.log('Options updated. Saving to browser local storage.')
        localStorage.options = JSON.stringify(value)
    })

    load_votes()
}


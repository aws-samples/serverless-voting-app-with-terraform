<script>
    export let vote;
    export let value;

    function count_vote() {
        value += 1;
    }

</script>


<div class="card card-compact w-auto bg-base-100 shadow-xl m-2">
    <figure><img src="/images/{vote}.jpg" alt="{vote}" /></figure>
    <div class="card-body">
        <div class="card-actions justify-between items-center">
    <h2 class="card-title">Votes: {value}</h2>
            <button class="btn btn-primary" on:click="{() => count_vote()}">I love {vote}s!</button>
        </div>
    </div>
</div>

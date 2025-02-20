<script>
  import { options, load_data } from '$lib/stores/votes.js';
</script>

<div class="flex-none">
  <button 
    type="button" 
    class="btn btn-square btn-ghost modal-button" 
    on:click={() => document.getElementById('option-modal').checked = true}
    on:keydown={(e) => e.key === 'Enter' && (document.getElementById('option-modal').checked = true)}
    aria-label="Open settings"
  >
    <svg
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
      class="inline-block w-5 h-5 stroke-current"
      aria-hidden="true"
    ><path
      stroke-linecap="round"
      stroke-linejoin="round"
      stroke-width="2"
      d="M4 6h16M4 12h16M4 18h16"
    /></svg>
  </button>

  <input type="checkbox" id="option-modal" class="modal-toggle" />
  <div class="modal">
    <div class="form-control modal-box" role="dialog" aria-labelledby="modal-title">
      <button 
        type="button"
        class="btn btn-sm btn-circle absolute right-2 top-2"
        on:click={() => document.getElementById('option-modal').checked = false}
        on:keydown={(e) => e.key === 'Enter' && (document.getElementById('option-modal').checked = false)}
        aria-label="Close settings"
      >✕</button>
      <h2 id="modal-title" class="font-bold text-2xl">Config Options</h2>
      
      <div class="label">
        <span class="label-text font-bold text-xl">API Gateway Endpoint (without trailing slash '/')</span>
      </div>
      <input
        type="text"
        name="apigw"
        bind:value={$options.apigw_endpoint}
        placeholder="Type here"
        class="input input-bordered w-full"
      />
      
      <div class="label">
        <span class="label-text font-bold text-xl">Cognito Identity Pool ID</span>
      </div>
      <input
        type="text"
        name="cognito"
        bind:value={$options.cognito_identity_pool_id}
        placeholder="Type here"
        class="input input-bordered w-full"
      />
      
      <div class="label">
        <span class="label-text font-bold text-xl">IoT Core Endpoint</span>
      </div>
      <input
        type="text"
        name="iotcore"
        bind:value={$options.iotcore_endpoint}
        placeholder="Type here"
        class="input input-bordered w-full"
      />
      
      <div class="modal-action">
        <button 
          type="button" 
          class="btn" 
          on:click={() => {
            load_data();
            document.getElementById('option-modal').checked = false;
          }}
        >Save</button>
      </div>
    </div>
  </div>
</div>

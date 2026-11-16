using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using Slugger.Playground;

WebAssemblyHostBuilder builder = WebAssemblyHostBuilder.CreateDefault(args);

// One root component, mounted where index.html's shell sits. No router: see Playground.razor.
builder.RootComponents.Add<Playground>("#app");
builder.RootComponents.Add<HeadOutlet>("head::after");

await builder.Build().RunAsync();

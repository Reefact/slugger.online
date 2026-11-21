#region Usings declarations

using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;

using Slugger.Playground;

#endregion

WebAssemblyHostBuilder builder = WebAssemblyHostBuilder.CreateDefault(args);

// The catalogue's themes and the command line's options are published beside this application
// rather than compiled into it (§7.5, §10.5), so they are read over the same origin that served
// it — which is all the content policy allows, and all §12.3 leaves standing. The base address
// is the prefix of §12.2: every path below is relative to it.
builder.Services.AddScoped(_ => new HttpClient { BaseAddress = new Uri(builder.HostEnvironment.BaseAddress) });

// One root component, mounted where index.html's shell sits. No router: see Playground.razor.
builder.RootComponents.Add<Playground>("#app");
builder.RootComponents.Add<HeadOutlet>("head::after");

await builder.Build().RunAsync();

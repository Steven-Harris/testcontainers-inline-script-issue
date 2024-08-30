using Xunit;
using DotNet.Testcontainers.Builders;
using DotNet.Testcontainers.Containers;

namespace testcontainers_inline_script_issue;

public class Test
{
    [Fact]
    public async Task StartTestContainer()
    {
        var image = new ImageFromDockerfileBuilder()
                    .WithDockerfileDirectory(CommonDirectoryPath.GetProjectDirectory(), string.Empty)
                    .WithDockerfile("Dockerfile")
                    .WithName("spanner-emulator")
                    .Build();
        await image.CreateAsync();
        
        var spanner = new ContainerBuilder()
                      .WithImage("spanner-emulator")
                      .WithPortBinding(9010, true)
                      .WithWaitStrategy(Wait.ForUnixContainer().UntilContainerIsHealthy())
                      .Build();
        
        await spanner.StartAsync();
        
        Assert.Equal(TestcontainersStates.Running, spanner.State);
    }
}
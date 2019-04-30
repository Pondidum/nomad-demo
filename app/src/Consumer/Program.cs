using System;
using System.Threading;
using System.Threading.Tasks;
using Jobs;
using MassTransit;
using Microsoft.Extensions.Configuration;

namespace Consumer
{
	class Program
	{
		private static Random Random = new Random();

		public static async Task Main(string[] args)
		{
			var config = new Configuration();
			new ConfigurationBuilder()
				.AddEnvironmentVariables()
				.AddJsonFile("appsettings.json")
				.Build()
				.Bind(config);

			var broker = await config.GetRabbitBroker();

			var bus = Bus.Factory.CreateUsingRabbitMq(c =>
			{
				var host = c.Host(broker, r =>
				{
					r.Username("admin");
					r.Password("admin");
				});

				c.ReceiveEndpoint(host, config.QueueName, ep => ep.Handler<Job>(OnJob));
			});

			await bus.StartAsync();

			var pause = new ManualResetEvent(false);
			Console.WriteLine("Press Ctrl+C to exit");

			Console.CancelKeyPress += (sender, e) =>
			{
				Console.WriteLine("Shutting down...");
				e.Cancel = true;
				pause.Set();
			};

			pause.WaitOne();
			await bus.StopAsync();
			config.Dispose();
		}

		private static async Task OnJob(ConsumeContext<Job> context)
		{
			var duration = TimeSpan.FromSeconds(Random.Next(0, 5));

			await Task.Delay(duration);

			Console.WriteLine($"Processing {context.Message.Sequence} took {duration.TotalSeconds} seconds");
		}
	}
}

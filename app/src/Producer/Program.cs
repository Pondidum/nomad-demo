using System;
using System.Linq;
using System.Threading.Tasks;
using Jobs;
using MassTransit;

namespace Producer
{
	class Program
	{
		public static async Task Main(string[] args)
		{
			var config = new Configuration();
			var broker = await config.GetRabbitBroker();

			var bus = Bus.Factory.CreateUsingRabbitMq(c =>
			{
				c.Host(broker, r =>
				{
					r.Username("guest");
					r.Password("guest");
				});
			});

			await bus.StartAsync();

			var total = args
				.Where(x => int.TryParse(x, out _))
				.Select(int.Parse)
				.DefaultIfEmpty(1000)
				.First();

			Console.WriteLine($"Publishing {total} jobs...");

			for (var i = 0; i < total; i++)
				await bus.Publish(
					new Job { Sequence = i },
					context => context.MessageId = Guid.NewGuid()
				);

			await bus.StopAsync();
			config.Dispose();

			Console.WriteLine("Done");
		}
	}
}

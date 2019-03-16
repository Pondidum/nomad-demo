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
			var bus = Bus.Factory.CreateUsingRabbitMq(c =>
			{
				var host = c.Host(new Uri("rabbitmq://localhost"), r =>
				{
					r.Username("guest");
					r.Password("guest");
				});
			});

			await bus.StartAsync();

			var total = args
				.Where(x => int.TryParse(x, out _))
				.Select(int.Parse)
				.DefaultIfEmpty(10)
				.First();

			Console.WriteLine($"Publishing {total} jobs...");

			for (var i = 0; i < total; i++)
				await bus.Publish(
					new Job { Sequence = i },
					context => context.MessageId = Guid.NewGuid()
				);

			await bus.StopAsync();

			Console.WriteLine("Done");
		}
	}
}

namespace Jobs
{
	public class Job
	{
		public int Sequence { get; set; }
	}
}

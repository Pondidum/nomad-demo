using System;
using System.Threading.Tasks;
using Jobs;
using MassTransit;

namespace Consumer
{
	class Program
	{
		private static Random Random = new Random();

		public static async Task Main(string[] args)
		{
			var bus = Bus.Factory.CreateUsingRabbitMq(c =>
			{
				var host = c.Host(new Uri("rabbitmq://localhost"), r =>
				{
					r.Username("guest");
					r.Password("guest");
				});

				c.ReceiveEndpoint(host, "jobs", ep => { ep.Handler<Job>(OnJob); });
			});

			await bus.StartAsync();

			Console.WriteLine("Press any key to exit");
			Console.ReadKey();

			await bus.StopAsync();
		}

		private static async Task OnJob(ConsumeContext<Job> context)
		{
			var duration = TimeSpan.FromSeconds(Random.Next(0, 5));

			await Task.Delay(duration);

			Console.WriteLine($"Processing {context.Message.Sequence} took {duration.TotalSeconds} seconds");
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

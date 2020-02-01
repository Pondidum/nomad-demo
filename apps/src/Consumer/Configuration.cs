using System;
using System.Threading.Tasks;
using Consul;

namespace Consumer
{
	public class Configuration : IDisposable
	{
		private static readonly Random Random = new Random();
		private readonly ConsulClient _consul;

		public Configuration()
		{
			_consul = new ConsulClient();
		}

		public async Task<Uri> GetRabbitBroker()
		{
			var service = await GetService("rabbitmq", "amqp");

			var builder = new UriBuilder
			{
				Scheme = "rabbitmq",
				Host = service.Address,
				Port = service.ServicePort
			};

			return builder.Uri;
		}

		private async Task<CatalogService> GetService(string serviceName, string tag = null)
		{
			var service = await _consul.Catalog.Service(serviceName, tag);
			var index = Random.Next(0, service.Response.Length - 1);

			return service.Response[index];
		}

		public void Dispose()
		{
			_consul.Dispose();
		}
	}
}

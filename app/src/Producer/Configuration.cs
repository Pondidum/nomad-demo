using System;
using System.Linq;
using System.Threading.Tasks;
using Consul;

namespace Producer
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
			var instance = service.Response[Random.Next(0, service.Response.Length - 1)];

			return instance;
		}

		public void Dispose()
		{
			_consul.Dispose();
		}
	}
}

using System;
using System.Linq;
using System.Threading.Tasks;
using Consul;

namespace Consumer
{
	public class Configuration : IDisposable
	{
		private readonly ConsulClient _consul;

		public Configuration()
		{
			_consul = new ConsulClient();
		}

		public string QueueName { get; set; }

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
			var instance = service.Response.First();

			return instance;
		}

		public void Dispose()
		{
			_consul.Dispose();
		}
	}
}

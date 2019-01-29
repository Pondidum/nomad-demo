using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;

namespace HelloApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class StatusController : ControllerBase
    {
        private static int _requests;

        [HttpGet]
        public object Get()
        {
            return new {
                version = GetType().Assembly.GetName().Version.ToString(),
                host = Environment.MachineName,
                requestCount = _requests++
            };
        }
    }
}

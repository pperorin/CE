using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using calculator.Models;

using System;
using System.Text;
using System.Data;

namespace calculator.Controllers
{
    public class HomeController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }

        [Produces("text/html")]
        public IActionResult Calculate(string number)
        {
            CalculatorModel cal = new CalculatorModel();
            string value = new DataTable().Compute(number, null).ToString();
            cal.CalculateValue = value;
            return Content(cal.CalculateValue, "text/html", Encoding.UTF8); 
        }

        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}

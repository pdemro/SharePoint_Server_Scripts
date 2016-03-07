using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;
using Microsoft.SharePoint.Client;
using System.Security;
using System.Threading;

namespace ApplyCustomActions
{
    public class Program
    {
        static void Main(string[] args)
        {
            ConsoleColor defaultForeground = Console.ForegroundColor;

            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine("Enter the URL of the SharePoint Online site:");

            Console.ForegroundColor = defaultForeground;
            //string webUrl = Console.ReadLine();
            string webUrl = "https://mod821521.sharepoint.com/sites/demroTeam/test2";

            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine("Enter your user name (ex: kirke@mytenant.microsoftonline.com):");
            Console.ForegroundColor = defaultForeground;
            //string userName = Console.ReadLine();
            string userName = "pdemro@mod821521.onmicrosoft.com";

            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine("Enter your password.");
            Console.ForegroundColor = defaultForeground;

            

            //var password = new SecureString();
            var password = GetPasswordFromConsoleInput();
            //foreach (var c in passwordArray)
            //{
            //    password.AppendChar(c);
            //}

            
            using (var context = new ClientContext(webUrl))
            {
                context.Credentials = new SharePointOnlineCredentials(userName, password);
                context.Load(context.Web, w => w.Title, w=> w.Url);
                context.ExecuteQuery();

                Console.ForegroundColor = ConsoleColor.White;
                Console.WriteLine("Your site title is: " + context.Web.Title);
                Console.WriteLine("Setting custom action..");
                //CustomActionHelpers.DeleteCustomAction(context.Web);
                CustomActionHelpers.SetCustomAction(context.Web);

                Console.ForegroundColor = defaultForeground;
                Console.ReadLine();
            }

        }

        private static SecureString GetPasswordFromConsoleInput()
        {
            ConsoleKeyInfo info;

            //Get the user's password as a SecureString
            SecureString securePassword = new SecureString();
            do
            {
                info = Console.ReadKey(true);
                if (info.Key != ConsoleKey.Enter)
                {
                    securePassword.AppendChar(info.KeyChar);
                }
            }
            while (info.Key != ConsoleKey.Enter);
            return securePassword;
        }
    }
}

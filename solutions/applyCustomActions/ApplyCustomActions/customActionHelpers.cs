using System;
using System.Collections.Generic;
using System.Diagnostics.Contracts;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.SharePoint.Client;

namespace ApplyCustomActions
{
    public static class CustomActionHelpers
    {
        private const string customActionName = "Test Custom Action";

        public static void SetCustomAction(Web web)
        {
            var targetAction = web.UserCustomActions.Add();

            targetAction.Name = customActionName;
            targetAction.Description = "Test Custom Action Description";
            targetAction.Location = "ScriptLink";
            targetAction.Sequence = 100;
            targetAction.ScriptSrc = "~SiteCollection/_catalogs/_app/test/test.js";

            targetAction.Update();

            web.Context.Load(web, w => w.UserCustomActions);
            web.Context.ExecuteQueryRetry();
        }

        public static void DeleteCustomAction(Web web)
        {
            var existingActions = web.UserCustomActions;

            web.Context.Load(existingActions);
            web.Context.ExecuteQueryRetry();

            var targetAction = web.UserCustomActions.FirstOrDefault(uca => uca.Name == customActionName);
            if (targetAction != null)
            {
                targetAction.DeleteObject();
                web.Context.ExecuteQueryRetry();
                Console.WriteLine("Deleted custom action {0} from site {1}", customActionName, web.Url);
            }
            else
            {
                Console.WriteLine("Did not find custom action {0} on site {1}", customActionName, web.Url);
            }
        }
    }
}

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
        public static void SetCustomAction(Web web)
        {
            var targetAction = web.UserCustomActions.Add();

            targetAction.Name = "Test Custom Action";
            targetAction.Description = "Test Custom Action Description";
            targetAction.Location = "ScriptLink";
            targetAction.Sequence = 100;
            targetAction.ScriptSrc = "~SiteCollection/_catalogs/_app/test/test.js";

            targetAction.Update();

            web.Context.Load(web, w => w.UserCustomActions);
            web.Context.ExecuteQueryRetry();
        }

        public static void Test()
        {
            //do nothing
        }
    }
}

﻿using SecurityEssentials.Acceptance.Tests.Web.Pages;
using TechTalk.SpecFlow;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace SecurityEssentials.Acceptance.Tests.Web.Extensions
{
	[Binding]
	public class UserEditSteps
	{

		[Given(@"I enter the following change account information data:")]
		public void GivenIEnterTheFollowingChangeAccountInformationData(Table table)
		{
			var page = ScenarioContext.Current.GetPage<UserEditPage>();
			page.EnterDetails(table);
		}

		[When(@"I submit the manage account form")]
		public void WhenISubmitTheManageAccountForm()
		{
			var page = ScenarioContext.Current.GetPage<UserEditPage>();
			page.ClickSubmit();
		}

		[Scope(Scenario = "I can change my account information")]
		[Then(@"A confirmation message '(.*)' is shown")]
		public void ThenAConfirmationMessageIsShown(string message)
		{
			var page = ScenarioContext.Current.GetPage<UserEditPage>();
			Assert.IsTrue(page.GetStatusMessage().Contains(message));
		}

	}
}

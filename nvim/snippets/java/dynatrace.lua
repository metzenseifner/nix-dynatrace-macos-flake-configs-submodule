return {
  s("switchBackToSecondGenUI", fmt([[
    private void switchBackToSecondGenUI() {
      if (new Dock(driver).isPresent()) {
        dashboardPage.openUserMenu();
        dashboardPage.clickLatestDynatraceSwitch();
        Wait.waitUntilAllLoadingIndicatorsAreInvisible(WebUI.ALL_LOADING_INDICATORS_LOCATOR, Duration.ofSeconds(5), Duration.ofSeconds(30), driver);
        Assert.assertTrue(dashboardPage.isUserMenuIn2ndGenVisible(), "Switching to 2nd Gen UI failed.");
      }
    }
  ]], {}, {delimiters="[]"}))
}

@test1
Feature: Amazon create account page should have verification on all  the fields

  Scenario:Error validation name
    Given I am on the site homepage
    When I click on "sign_in_link" on the "Home" Page
    And I click on "register" on the "Sign In" Page

  Scenario:Error validation email
    Given I am on the site homepage
    When I click on "sign_in_link" on the "Home" Page
    And I click on "register" on the "Sign In" Page

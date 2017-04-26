@test2
Feature: Amazon create account page should have verification on all  the fields

  Scenario Outline: Invalid input on email field shoud return error -- Example of a fail
	Given I navigate to the Create Account Page
	And I enter "test@test.com" into all the fields on the page
	When I clear the "<field>" field on the Create Account Page
	And I click on submit on the Create Account Page
	Then the "<error>" on the Create Account Page should be visible and say "<expected_text>"

  Examples:
	| field            | error                          | expected_text            |
	| name             | missing_name_error             | Enter your name          |
	| email            | missing_email_error            | Enter your email         |
	| password         | missing_password_error         | Enter your password      |
	| confirm_password | missing_confirm_password_error | Type your password again |

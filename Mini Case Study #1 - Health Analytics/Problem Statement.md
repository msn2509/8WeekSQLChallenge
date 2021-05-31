
> Comes from the 'Serious SQL' by Danny Ma: Written in PostgreSQL

We’ve just received an urgent request from the General Manager of Analytics at Health Co requesting our assistance with their analysis of the health.user_logs dataset.

## Business Questions
Before we start digging into the SQL script - let’s cover the business questions that we need to help the GM answer!

* How many unique users exist in the logs dataset?
* How many total measurements do we have per user on average?
* What about the median number of measurements per user?
* How many users have 3 or more measurements?
* How many users have 1,000 or more measurements?

Looking at the logs data - what is the number and percentage of the active user base who:
* Have logged blood glucose measurements?
* Have at least 2 types of measurements?
* Have all 3 measures - blood glucose, weight and blood pressure?

For users that have blood pressure measurements:
* What is the median systolic/diastolic blood pressure values?

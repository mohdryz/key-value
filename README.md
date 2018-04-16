# Distributed Key-Value Pair
###### Written in ruby

####**Steps to run the application:**

Make sure you have the GCC compiler on your machine before hand. After setting up git, etc., do the following.

**1. Install ruby.**

For CentOS, Fedora, RHEL, use yum package installer:

`sudo yum install ruby`

For Ubuntu, Debain, use apt-get:

`sudo apt-get install ruby-full`

For MacOS High Sierra, Sierra and El Capitan, ruby 2.0 is included. Otherwise: 

`brew install ruby`

For others, please follow [this link](https://www.ruby-lang.org/en/documentation/installation)


**2. Run the following command to install bundler:**

`gem install bundler`

If asked root permissions, enter your root password.

**3. Clone the application in your workspace.**

**4. Run the following command to install dependencies from the home directory of the application:**

`bundle install`

> If it fails, run `sudo yum install ruby-devel`, `sudo apt-get install ruby-dev` or `sudo zypper install ruby-devel` according to your linux distribution.

**5. For running the unit tests, run:**

`ruby test_app.rb`

**6. To start the application, run:**

`rackup --host 0.0.0.0`

Make sure that the firewall is set to trusted so that two instances on two different nodes can interact.


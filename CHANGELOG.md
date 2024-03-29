# chef_software CHANGELOG

This file is used to list changes made in each version of the chef_software cookbook.

## 2.2.1 (2024-03-29)

- [Corey Hemminger] - fixed policy update bug, switched to ruby_block for additional output error detection

## 2.2.0 (2024-03-04)

- [Corey Hemminger] - Moved iam_policy and iam_user creation to resources, fixed idempotency in resources

## 2.1.2 (2023-03-31)

- [Corey Hemminger] - Hacky way of adding idempotency to chef-server org admin association

## 2.1.1 (2023-03-20)

- [Corey Hemminger] - Add safe navigation to .include method for automatev2 recipe

## 2.1.0 (20232-03-17)

- [Corey Hemminger] - Add Integrated Infra-Server user and org config to automate recipe

## 2.0.2 (2022-09-29)

- [Corey Hemminger] - Removed chef-ingredient reference to fork from policyfile

## 2.0.1 (2022-08-12)

- [Corey Hemminger] - Update changelog

## 2.0.0 (2022-08-12)

- [Corey Hemminger] - Update chef_automatev2 recipe to use iamv2 for user and policy creation
- [Corey Hemminger] - update chef_server to run chef-server-ctl upgrade vs chef-server-ctl reconfigure

## 1.1.1 (2022-08-02)

- [Corey Hemminger] - Fix server and supermarket's to run reconfigure after an update
- [Corey Hemminger] - Add github actions CI/CD pipelines and testing

## 1.1.0 (2020-08-07)

- [Corey Hemminger] - Modernize cookbook with policy file and other skeleton files

## 1.0.4 (2019-04-01)

- [Corey Hemminger] - Work around to make org admins idempotent

## 1.0.3 (2019-03-11)

- [Corey Hemminger] - Make description the same as long description

## 1.0.2 (2019-03-11)

- [Corey Hemminger] - Updated metadata description

## 1.0.1 (2019-01-14)

- [Corey Hemminger] - Updated readme and .kitchen.yml

## 1.0.0 (2018-12-21)

- [Corey Hemminger] - Initial Release

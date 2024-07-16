# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

## [2.0.0](https://github.com/le-phare/ansible-deploy/compare/v1.12.3...v2.0.0) (2024-07-16)

### Breaking changes

* **Ansible version:** upgrade Ansible version to 2.17 ([#56](https://github.com/le-phare/ansible-deploy/pull/56))([4da1bf8](https://github.com/le-phare/ansible-deploy/pull/56/commits/4da1bf8a7a638d27a512fb204635569d83c1d84f))

## [1.12.3](https://github.com/le-phare/ansible-deploy/compare/v1.12.2...v1.12.3) (2024-07-04)

### Bug Fixes

* **Ansible version:** fix Ansible version to 2.15.4  ([#55](https://github.com/le-phare/ansible-deploy/pull/55))([4da1bf8](https://github.com/le-phare/ansible-deploy/pull/55/commits/4da1bf8a7a638d27a512fb204635569d83c1d84f))

## [1.12.2](https://github.com/le-phare/ansible-deploy/compare/v1.12.1...v1.12.2) (2024-07-04)

### Bug Fixes

* **private registry:** add default value for lephare_gitlab_token and lephare_packagist_com_token  ([#54](https://github.com/le-phare/ansible-deploy/pull/54))([b71ddc1](https://github.com/le-phare/ansible-deploy/pull/54/commits/b71ddc15d031f0fe2fafabd0381eebf5c6a42616))


## [1.12.1](https://github.com/le-phare/ansible-deploy/compare/v1.12.0...v1.12.1) (2024-07-03)

### Bug Fixes

* **Dockerfile:** add sshpass package ([#52](https://github.com/le-phare/ansible-deploy/pull/52))([72dd8ad](https://github.com/le-phare/ansible-deploy/pull/52/commits/72dd8ad064a212f3bca23396b738d1e9e0ce4665))

## [1.12.0](https://github.com/le-phare/ansible-deploy/compare/v1.11.0...v1.12.0) (2024-07-02)

### Features

* **private registry:** allow set gitlab-token Composer auth ([#51](https://github.com/le-phare/ansible-deploy/pull/51))([6abce76](https://github.com/le-phare/ansible-deploy/pull/51/commits/6abce764e7654c7b807c63b68b66f3c8ee85c280))

## [1.11.0](https://github.com/le-phare/ansible-deploy/compare/v1.10.1...v1.11.0) (2023-09-28)

### Features

* **publish assets:** allow to add rsync options ([#46](https://github.com/le-phare/ansible-deploy/pull/46))([a7fd9d](https://github.com/le-phare/ansible-deploy/commit/a7fd9df3e5f678a16a864b78378aa42aba594d79))

## [1.10.1](https://github.com/le-phare/ansible-deploy/compare/v1.10.0...v1.10.1) (2023-09-20)

### Bug Fixes

* **cachetool:** download specific cachetool versions from gordalina instead of inexistent github.com releases ([#18](https://github.com/le-phare/ansible-deploy/issues/18))([e59455](https://github.com/le-phare/ansible-deploy/commit/e59455d19248a37e38642c6ff2e767a4605e85e6))

## [1.10.0](https://github.com/le-phare/ansible-deploy/compare/v1.9.0...v1.10.0) (2023-09-20)

### Features

* **files:** allow deleting files after deployment ([#44](https://github.com/le-phare/ansible-deploy/issues/44))([6454ab](https://github.com/le-phare/ansible-deploy/commit/6454ab8b98d9634deda63ccfd81e20576e3bf000))

## [1.9.0](https://github.com/le-phare/ansible-deploy/compare/v1.8.1...v1.9.0) (2023-08-25)

### Features

* **cachetool:** add support for fastcgi adapter ([#37](https://github.com/le-phare/ansible-deploy/issues/37))([3bda745](https://github.com/le-phare/ansible-deploy/commit/3bda745b50f8ef1756e865ff6637d99955fe15cc))

### Bug Fixes

* **composer:** use composer v2 home directory ([9b8e6d8](https://github.com/le-phare/ansible-deploy/commit/9b8e6d87e1ac9e21e9541b8a8280a2ab5da6c5a6))

### [1.8.1](https://github.com/le-phare/ansible-deploy/compare/v1.8.0...v1.8.1) (2023-01-05)

## [1.8.0](https://github.com/le-phare/ansible-deploy/compare/v1.7.1...v1.8.0) (2023-01-05)


### Features

* **cachetool:** generate cachetool configuration file ([2014472](https://github.com/le-phare/ansible-deploy/commit/201447231d90698565e68f2a6906c647b79b945f))


### Bug Fixes

* **cachetool:** add missing task to clear file stats ([#31](https://github.com/le-phare/ansible-deploy/issues/31)) ([4dbc67a](https://github.com/le-phare/ansible-deploy/commit/4dbc67ace6c71eb5aed2f40dd39779106d34b8b4))

### [1.7.1](https://github.com/le-phare/ansible-deploy/compare/v1.7.0...v1.7.1) (2022-11-22)


### Bug Fixes

* **permissions:** remove recursivity when changing permissions ([#30](https://github.com/le-phare/ansible-deploy/issues/30)) ([1d8d6b2](https://github.com/le-phare/ansible-deploy/commit/1d8d6b2951bab9eedd1d3092aa118d054cd7d145))

## [1.7.0](https://github.com/le-phare/ansible-deploy/compare/v1.6.1...v1.7.0) (2022-11-07)


### Features

* **cachetool:** allows to define retries and delay ([#28](https://github.com/le-phare/ansible-deploy/issues/28)) ([5e94bb6](https://github.com/le-phare/ansible-deploy/commit/5e94bb67669283bb8d09646484468d2087db47d6))
* **permissions:** add support for group acls ([#29](https://github.com/le-phare/ansible-deploy/issues/29)) ([a2ff2e8](https://github.com/le-phare/ansible-deploy/commit/a2ff2e869ec40939cba6d8679e99c6a29ba55011))

### Dependencies

* **db-pull** update to [v1.2.0](https://github.com/le-phare/ansible-db-pull/blob/master/CHANGELOG.md)

### [1.6.1](https://github.com/le-phare/ansible-deploy/compare/v1.6.0...v1.6.1) (2022-10-06)


### Bug Fixes

* **composer:** ignore error if dump-env is not available ([#27](https://github.com/le-phare/ansible-deploy/issues/27)) ([630c589](https://github.com/le-phare/ansible-deploy/commit/630c5894f819b3b79866fd4300fbfe5c05ae5c95))
* **php:** use given php path to gather facts ([#26](https://github.com/le-phare/ansible-deploy/issues/26)) ([5d9fa7d](https://github.com/le-phare/ansible-deploy/commit/5d9fa7d24df2b6a911f6449b82a52b17c6926554))

## [1.6.0](https://github.com/le-phare/ansible-deploy/compare/v1.5.1...v1.6.0) (2022-10-04)


### Features

* **composer:** dump environment during deployment  ([#25](https://github.com/le-phare/ansible-deploy/issues/25)) ([70369ed](https://github.com/le-phare/ansible-deploy/commit/70369ed0e335a2dc677ac3c26aca181491b6c6e1))

### [1.5.1](https://github.com/le-phare/ansible-deploy/compare/v1.5.0...v1.5.1) (2022-07-18)


### Bug Fixes

* **syfmony/messenger:** change working dir to run messenger command ([f063c0c](https://github.com/le-phare/ansible-deploy/commit/f063c0c1dca04498ce7123476b0ea9e91b6fda87))

## [1.5.0](https://github.com/le-phare/ansible-deploy/compare/v1.4.0...v1.5.0) (2022-07-02)


### Features

* **symfony/messenger:** add support for messenger scheduling ([#24](https://github.com/le-phare/ansible-deploy/issues/24)) ([c7be08e](https://github.com/le-phare/ansible-deploy/commit/c7be08ecefbc9f78026694d8c2b8546bc288755c))

## [1.4.0](https://github.com/le-phare/ansible-deploy/compare/v1.3.1...v1.4.0) (2022-06-15)


### Features

* add support for symfony secrets ([#22](https://github.com/le-phare/ansible-deploy/issues/22)) ([6c7014d](https://github.com/le-phare/ansible-deploy/commit/6c7014d6a680561151f61a31df43dc69498e51ec))
* **cachetool:** allows to pass arbitrary options to cachetool commands ([#23](https://github.com/le-phare/ansible-deploy/issues/23)) ([1878451](https://github.com/le-phare/ansible-deploy/commit/1878451e29fd0914894fc184fa53e7470ad6dec5))

### [1.3.1](https://github.com/le-phare/ansible-deploy/compare/v1.3.0...v1.3.1) (2022-03-30)


### Bug Fixes

* **composer:** update template path based on directory location ([#21](https://github.com/le-phare/ansible-deploy/issues/21)) ([caeae0f](https://github.com/le-phare/ansible-deploy/commit/caeae0f8118f90097e0b715b744d7c7e8bff662e))

## [1.3.0](https://github.com/le-phare/ansible-deploy/compare/v1.2.4...v1.3.0) (2022-03-29)


### Features

* **composer:** allow to configure composer private registry authentication ([#20](https://github.com/le-phare/ansible-deploy/issues/20)) ([5c4b73d](https://github.com/le-phare/ansible-deploy/commit/5c4b73d86b53c9a4ff4212d3b513dbe58b6c01cb))

### [1.2.4](https://github.com/le-phare/ansible-deploy/compare/v1.2.3...v1.2.4) (2022-03-17)


### Bug Fixes

* **cachetool:** check for existence before checking if path is a directory ([#17](https://github.com/le-phare/ansible-deploy/issues/17)) ([36e0ddb](https://github.com/le-phare/ansible-deploy/commit/36e0ddb3f44e0c617b9cd665d0a53a5d24d45a38))

### [1.2.3](https://github.com/le-phare/ansible-deploy/compare/v1.2.2...v1.2.3) (2022-03-14)


### Bug Fixes

* **cachetool:** update failure check with the correct variable ([e236e17](https://github.com/le-phare/ansible-deploy/commit/e236e17512d18e323c753b62c6deda2083756d51))

### [1.2.2](https://github.com/le-phare/ansible-deploy/compare/v1.2.1...v1.2.2) (2022-03-14)


### Bug Fixes

* **cachetool:** add an additional check if given path is not a directory ([cb9d269](https://github.com/le-phare/ansible-deploy/commit/cb9d26944278523b2a1cf1134eb4021a5353cf25))

### [1.2.1](https://github.com/le-phare/ansible-deploy/compare/v1.2.0...v1.2.1) (2022-03-09)


### Bug Fixes

* **cachetool:** better handling of the 'latest' version ([22cbe69](https://github.com/le-phare/ansible-deploy/commit/22cbe69fe394c724664c686fe82d4038efe66720))

## [1.2.0](https://github.com/le-phare/ansible-deploy/compare/v1.1.3...v1.2.0) (2022-03-09)


### Features

* **cachetool:** guess the correct cachetool version to use based on php_facts ([#16](https://github.com/le-phare/ansible-deploy/issues/16)) ([3e9401c](https://github.com/le-phare/ansible-deploy/commit/3e9401ccd06d7dd704d82afc084e4f6a141be644))

### [1.1.3](https://github.com/le-phare/ansible-deploy/compare/v1.1.2...v1.1.3) (2021-11-19)


### Bug Fixes

* **hooks:** add a variable `lephare_symfony_before_composer_tasks_file` to hook before composer task ([98f7518](https://github.com/le-phare/ansible-deploy/commit/98f75186dc58211b508a5174c59bd64671c7e3f0))

### [1.1.2](https://github.com/le-phare/ansible-deploy/compare/v1.1.1...v1.1.2) (2021-11-18)

### [1.1.1](https://github.com/le-phare/ansible-deploy/compare/v1.1.0...v1.1.1) (2021-11-18)

## 1.1.0 (2021-11-18)


### Features

* add latest commit message on notify slack ([a2935e5](https://github.com/le-phare/ansible-deploy/commit/a2935e53ff26d1ef438fdd78dfdc773ad609e859))
* Add stale workflow ([45d8fcc](https://github.com/le-phare/ansible-deploy/commit/45d8fcc9e97dfea5c4cac4e9a5bf325459388d9b))
* notify slack channel ([25366db](https://github.com/le-phare/ansible-deploy/commit/25366dbc6fded848120dd5c156de657a5a4d16e8))
* **sentry:** allows to override sentry organization setting ([c18443b](https://github.com/le-phare/ansible-deploy/commit/c18443b747bba0ab18226dfadf626c985573d88e))
* **sentry:** update release version to 12 characters ([b0f29a8](https://github.com/le-phare/ansible-deploy/commit/b0f29a86f0dffd0d1b5ee22a0b7f2470e4fed252))
* setup CI build for ansible image ([a88f260](https://github.com/le-phare/ansible-deploy/commit/a88f2605e613be93ecb1cf0b18425ee4c5043767))


### Bug Fixes

* add slack domain ([8db0db7](https://github.com/le-phare/ansible-deploy/commit/8db0db72c24ae759be4e1027c7351dd43fabe416))
* add vars required for slack module ([b6c5c29](https://github.com/le-phare/ansible-deploy/commit/b6c5c296c44926410e3864f0ba172944552dfda5))
* **docker:** fix docker build by adding rust and cargo to the build environment ([a73eef1](https://github.com/le-phare/ansible-deploy/commit/a73eef16a08706aaf45a7eb4e13b1a608793189f))
* remove files non related to this pr ([c142a63](https://github.com/le-phare/ansible-deploy/commit/c142a63745d91bc4fb673984ad08f8c375b6ef83))
* rename filename notify_slack.yml ([2dc8cda](https://github.com/le-phare/ansible-deploy/commit/2dc8cda08241e08ed5ff8a8ae230ad64c40b117d))
* rename filename notify_slack.yml ([59989ba](https://github.com/le-phare/ansible-deploy/commit/59989baefe5e183ae50287a0782bf578744fe979))
* rename lephare_notify_slack_deploy ([cd2ff98](https://github.com/le-phare/ansible-deploy/commit/cd2ff982c14d28063ec3ead2d1af436b16448eda))
* rename vars ([fb231e8](https://github.com/le-phare/ansible-deploy/commit/fb231e8e26502b8499f1bdfba1388cb1a98c0fb0))
* switch to le-phare/ansible-db-pull ([ac51092](https://github.com/le-phare/ansible-deploy/commit/ac510922319fd26ff6045ce60667b0ae989b8481))
* update dockerfile path ([b63fd87](https://github.com/le-phare/ansible-deploy/commit/b63fd8789c32219de520c154ae6413b45b35fd63))
* update secrets name ([cace411](https://github.com/le-phare/ansible-deploy/commit/cace41191d2df38369c909592fe6a7d43de55fe1))

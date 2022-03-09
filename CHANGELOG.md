# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

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

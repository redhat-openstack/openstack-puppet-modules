# Change Log

## [v1.0.1](https://github.com/Yelp/puppet-uchiwa/tree/v1.0.1) (2015-12-07)
[Full Changelog](https://github.com/Yelp/puppet-uchiwa/compare/v1.0.0...v1.0.1)

**Closed issues:**

- Changelog [\#30](https://github.com/Yelp/puppet-uchiwa/issues/30)

**Merged pull requests:**

- Update apt key id [\#62](https://github.com/Yelp/puppet-uchiwa/pull/62) ([queeno](https://github.com/queeno))

## [v1.0.0](https://github.com/Yelp/puppet-uchiwa/tree/v1.0.0) (2015-12-04)
[Full Changelog](https://github.com/Yelp/puppet-uchiwa/compare/0.3.0...v1.0.0)

**Closed issues:**

- Support the users attribute [\#46](https://github.com/Yelp/puppet-uchiwa/issues/46)
- Duplicate Apt Resource [\#36](https://github.com/Yelp/puppet-uchiwa/issues/36)
- JSON acceptance tests are failing [\#33](https://github.com/Yelp/puppet-uchiwa/issues/33)
- New puppet-uchiwa release? [\#25](https://github.com/Yelp/puppet-uchiwa/issues/25)

**Merged pull requests:**

- Introducing users param in puppet-uchiwa [\#61](https://github.com/Yelp/puppet-uchiwa/pull/61) ([queeno](https://github.com/queeno))
- Update sensu apt repo. [\#59](https://github.com/Yelp/puppet-uchiwa/pull/59) ([liamjbennett](https://github.com/liamjbennett))
- Update apt::source to use puppetlabs-apt 2.0.0+ [\#56](https://github.com/Yelp/puppet-uchiwa/pull/56) ([zxjinn](https://github.com/zxjinn))
- add a test for sensu\_api\_endpoints param [\#54](https://github.com/Yelp/puppet-uchiwa/pull/54) ([somic](https://github.com/somic))
- Changed example code from manage\_repo to install\_repo [\#52](https://github.com/Yelp/puppet-uchiwa/pull/52) ([standaloneSA](https://github.com/standaloneSA))
- Try to cleanup doc and un-nest api definitions [\#51](https://github.com/Yelp/puppet-uchiwa/pull/51) ([solarkennedy](https://github.com/solarkennedy))
- Properly type port number [\#50](https://github.com/Yelp/puppet-uchiwa/pull/50) ([DoriftoShoes](https://github.com/DoriftoShoes))
- fix lint [\#44](https://github.com/Yelp/puppet-uchiwa/pull/44) ([bleuchtang](https://github.com/bleuchtang))
- Fix warning when installing sensu apt repository [\#41](https://github.com/Yelp/puppet-uchiwa/pull/41) ([KoeSystems](https://github.com/KoeSystems))
- apt module 2.0.0 breaks apt::source extensively [\#39](https://github.com/Yelp/puppet-uchiwa/pull/39) ([bobtfish](https://github.com/bobtfish))
- Fixing Erroneous validations [\#37](https://github.com/Yelp/puppet-uchiwa/pull/37) ([magmax](https://github.com/magmax))
- Fix tests [\#35](https://github.com/Yelp/puppet-uchiwa/pull/35) ([pauloconnor](https://github.com/pauloconnor))
- Notify uchiwa service when package changes [\#34](https://github.com/Yelp/puppet-uchiwa/pull/34) ([timmow](https://github.com/timmow))
- Ensure uchiwa.json is not world-readable [\#32](https://github.com/Yelp/puppet-uchiwa/pull/32) ([nhinds](https://github.com/nhinds))
- Fix some issues with 3.7.\* Puppet [\#31](https://github.com/Yelp/puppet-uchiwa/pull/31) ([tayzlor](https://github.com/tayzlor))
- missing default host for sensu API [\#29](https://github.com/Yelp/puppet-uchiwa/pull/29) ([n1tr0g](https://github.com/n1tr0g))

## [0.3.0](https://github.com/Yelp/puppet-uchiwa/tree/0.3.0) (2014-12-11)
[Full Changelog](https://github.com/Yelp/puppet-uchiwa/compare/0.2.7...0.3.0)

**Closed issues:**

- Obscure Datacat errors from Uchiwa module [\#24](https://github.com/Yelp/puppet-uchiwa/issues/24)

**Merged pull requests:**

- Remove artifact of PR \#21 [\#28](https://github.com/Yelp/puppet-uchiwa/pull/28) ([jbussdieker](https://github.com/jbussdieker))
- Add the insecure parameter to the default endpoint [\#27](https://github.com/Yelp/puppet-uchiwa/pull/27) ([jbussdieker](https://github.com/jbussdieker))
- Fix JSON syntax [\#26](https://github.com/Yelp/puppet-uchiwa/pull/26) ([jbussdieker](https://github.com/jbussdieker))
- The refresh param now takes seconds rather than ms [\#23](https://github.com/Yelp/puppet-uchiwa/pull/23) ([queeno](https://github.com/queeno))
- Remove the stats param from the puppet module [\#22](https://github.com/Yelp/puppet-uchiwa/pull/22) ([queeno](https://github.com/queeno))
- Remove uchiwa::api and pass API data via class params [\#21](https://github.com/Yelp/puppet-uchiwa/pull/21) ([queeno](https://github.com/queeno))
- Fix puppet-uchiwa beaker tests [\#20](https://github.com/Yelp/puppet-uchiwa/pull/20) ([queeno](https://github.com/queeno))

## [0.2.7](https://github.com/Yelp/puppet-uchiwa/tree/0.2.7) (2014-11-10)
[Full Changelog](https://github.com/Yelp/puppet-uchiwa/compare/0.2.6...0.2.7)

**Closed issues:**

- Am I being inappropriately redirected? [\#18](https://github.com/Yelp/puppet-uchiwa/issues/18)
- uchiwa is not under the yelp namespace on the forge. [\#16](https://github.com/Yelp/puppet-uchiwa/issues/16)

**Merged pull requests:**

- Add beaker tests [\#17](https://github.com/Yelp/puppet-uchiwa/pull/17) ([petems](https://github.com/petems))

## [0.2.6](https://github.com/Yelp/puppet-uchiwa/tree/0.2.6) (2014-09-25)
[Full Changelog](https://github.com/Yelp/puppet-uchiwa/compare/0.2.5...0.2.6)

**Closed issues:**

- Explanation of  "incompatible with previous versions of the Sensu-Puppet module" [\#14](https://github.com/Yelp/puppet-uchiwa/issues/14)
- Rename to puppet-uchiwa? [\#10](https://github.com/Yelp/puppet-uchiwa/issues/10)

**Merged pull requests:**

- remove unnecessary str2bool in install.pp since input is already validated [\#13](https://github.com/Yelp/puppet-uchiwa/pull/13) ([lreed](https://github.com/lreed))

## [0.2.5](https://github.com/Yelp/puppet-uchiwa/tree/0.2.5) (2014-09-11)
[Full Changelog](https://github.com/Yelp/puppet-uchiwa/compare/0.2.4...0.2.5)

**Closed issues:**

- Duplicate declaration apt [\#11](https://github.com/Yelp/puppet-uchiwa/issues/11)
- setting install\_repo to false breaks module [\#8](https://github.com/Yelp/puppet-uchiwa/issues/8)

**Merged pull requests:**

- use anchor pattern to fix containment of uchiwa class [\#12](https://github.com/Yelp/puppet-uchiwa/pull/12) ([LarsFronius](https://github.com/LarsFronius))
- Fix for issue \#8 with package requiring repo [\#9](https://github.com/Yelp/puppet-uchiwa/pull/9) ([bjwschaap](https://github.com/bjwschaap))

## [0.2.4](https://github.com/Yelp/puppet-uchiwa/tree/0.2.4) (2014-08-11)
[Full Changelog](https://github.com/Yelp/puppet-uchiwa/compare/0.2.3...0.2.4)

## [0.2.3](https://github.com/Yelp/puppet-uchiwa/tree/0.2.3) (2014-08-08)
[Full Changelog](https://github.com/Yelp/puppet-uchiwa/compare/0.2.2...0.2.3)

## [0.2.2](https://github.com/Yelp/puppet-uchiwa/tree/0.2.2) (2014-08-08)
[Full Changelog](https://github.com/Yelp/puppet-uchiwa/compare/0.2.0...0.2.2)

## [0.2.0](https://github.com/Yelp/puppet-uchiwa/tree/0.2.0) (2014-08-07)
[Full Changelog](https://github.com/Yelp/puppet-uchiwa/compare/0.1.1...0.2.0)

**Merged pull requests:**

- Fix template so it generates valid JSON [\#2](https://github.com/Yelp/puppet-uchiwa/pull/2) ([bodgit](https://github.com/bodgit))
- Clean up puppet-lint errors [\#1](https://github.com/Yelp/puppet-uchiwa/pull/1) ([bodgit](https://github.com/bodgit))

## [0.1.1](https://github.com/Yelp/puppet-uchiwa/tree/0.1.1) (2014-08-05)


\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
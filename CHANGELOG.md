# Changelog

## [2.6.0](https://github.com/stevearc/aerial.nvim/compare/v2.5.0...v2.6.0) (2025-06-04)


### Features

* add treesitter support for R ([#450](https://github.com/stevearc/aerial.nvim/issues/450)) ([fdf9e2e](https://github.com/stevearc/aerial.nvim/commit/fdf9e2e0b9d5e5a0b7861d76ef7cb0a28d345f9b))
* remove org support since nvim-treesitter dropped support ([a39c9a7](https://github.com/stevearc/aerial.nvim/commit/a39c9a7c49da0e04f35c749cbccdf838fd3ea58a))
* use async treesitter parsing in nvim 0.11 ([e749260](https://github.com/stevearc/aerial.nvim/commit/e749260729085f7c9250f073f1a71ba5650b4380))


### Bug Fixes

* add extra padding to icon in snacks picker ([#447](https://github.com/stevearc/aerial.nvim/issues/447)) ([8c63f41](https://github.com/stevearc/aerial.nvim/commit/8c63f41c13d250faeb3c848b61b06adedac737e5))
* correctly set `last` property in `snack.picker` integration ([#460](https://github.com/stevearc/aerial.nvim/issues/460)) ([0eb8722](https://github.com/stevearc/aerial.nvim/commit/0eb8722143fb02ab4a6ff2141a604dd9023b9ddd))
* eliminate deprecated warnings on nightly ([#457](https://github.com/stevearc/aerial.nvim/issues/457)) ([95825c9](https://github.com/stevearc/aerial.nvim/commit/95825c9c07e64ecdba657b20c12bc11ece7b38cb))
* **latex:** support \chapter and \part as symbols ([#461](https://github.com/stevearc/aerial.nvim/issues/461)) ([2e00d1d](https://github.com/stevearc/aerial.nvim/commit/2e00d1d4248f08dddfceacb8d2996e51e13e00f6))
* prevent Aerial float window from closing on split ([#462](https://github.com/stevearc/aerial.nvim/issues/462)) ([a2af699](https://github.com/stevearc/aerial.nvim/commit/a2af699b346c2baabe2ef976f253ba6c842584d8))
* **ruby:** don't detect stray method calls as Rspec or Shoulda blocks ([8933275](https://github.com/stevearc/aerial.nvim/commit/89332755bf2bd94e408fad59e89028c4205dd040))
* select snacks picker element based on cursor position ([#458](https://github.com/stevearc/aerial.nvim/issues/458)) ([8c89f27](https://github.com/stevearc/aerial.nvim/commit/8c89f27b5792e7691578cf05368a110702e4a1e9))
* symbol hierarchy for markdown backend ([#454](https://github.com/stevearc/aerial.nvim/issues/454)) ([9ebc135](https://github.com/stevearc/aerial.nvim/commit/9ebc13583cff447f5493a63e99dfca526b3c3088))
* **telescope:** correct highlight offset computation ([#465](https://github.com/stevearc/aerial.nvim/issues/465)) ([5c0df16](https://github.com/stevearc/aerial.nvim/commit/5c0df1679bf7c814c924dc6646cc5291daca8363))
* vim.treesitter.is_ancestor no longer returns true for identical nodes ([1d3cf8b](https://github.com/stevearc/aerial.nvim/commit/1d3cf8bd8c321b70a9f61e7872c2fca8890fd151))

## [2.5.0](https://github.com/stevearc/aerial.nvim/compare/v2.4.0...v2.5.0) (2025-02-14)


### Features

* add treesitter support for nushell ([#438](https://github.com/stevearc/aerial.nvim/issues/438)) ([4c0c3bd](https://github.com/stevearc/aerial.nvim/commit/4c0c3bd8d8e539a8513bffa60ca171874251736f))
* **enforce:** treesitter symbol support ([#446](https://github.com/stevearc/aerial.nvim/issues/446)) ([a89f5e3](https://github.com/stevearc/aerial.nvim/commit/a89f5e39bbbd445242eebdbaac971e0c70ddd3b4))
* **fish:** add treesitter query ([#437](https://github.com/stevearc/aerial.nvim/issues/437)) ([d767bd8](https://github.com/stevearc/aerial.nvim/commit/d767bd8a92869c337c5a71707ce8287234e47b75))
* integrate with snacks picker ([e499ed3](https://github.com/stevearc/aerial.nvim/commit/e499ed3e30cd3682810fdd256e8f0175769f6db9))
* **php:** treesitter backend extracts function scope ([#436](https://github.com/stevearc/aerial.nvim/issues/436)) ([4c959cf](https://github.com/stevearc/aerial.nvim/commit/4c959cf65c5420d54b24b61a77b681dcfca0bc57))


### Bug Fixes

* default vim.lsp.buf.document_symbol behavior is unchanged ([#441](https://github.com/stevearc/aerial.nvim/issues/441)) ([63eb465](https://github.com/stevearc/aerial.nvim/commit/63eb4658b91b457518c44c958d5ceeb231778536))
* regenerate groovy snapshot for updated parser ([6d1c4ca](https://github.com/stevearc/aerial.nvim/commit/6d1c4ca65d2380630da122e97ae1ab37ccdca9e8))
* update djot query for upstream changes ([fc1e7a7](https://github.com/stevearc/aerial.nvim/commit/fc1e7a7a31ac835c499d3eec300632ee9f7d2c42))

## [2.4.0](https://github.com/stevearc/aerial.nvim/compare/v2.3.1...v2.4.0) (2024-12-21)


### Features

* add to jumplist before jumping ([#424](https://github.com/stevearc/aerial.nvim/issues/424)) ([247df21](https://github.com/stevearc/aerial.nvim/commit/247df216704cbe3cfa68e2ae5515c3485e281364))
* **djot:** treesitter support for djot ([#433](https://github.com/stevearc/aerial.nvim/issues/433)) ([8784058](https://github.com/stevearc/aerial.nvim/commit/8784058ba957dd84730fc76aec93f56c1b980583))
* treesitter support for swift ([#428](https://github.com/stevearc/aerial.nvim/issues/428)) ([fd7fbe3](https://github.com/stevearc/aerial.nvim/commit/fd7fbe36772d7a955815c90ff9b58523bfdb410d))


### Bug Fixes

* **java:** don't start methods at annotations ([#417](https://github.com/stevearc/aerial.nvim/issues/417)) ([60a7846](https://github.com/stevearc/aerial.nvim/commit/60a784614acb1d7695bd9ae0fee8ada1bf7b0c28))
* **julia:** update treesitter queries ([1ff1ab3](https://github.com/stevearc/aerial.nvim/commit/1ff1ab3891a823d967074cf949fe01770753e54a))

## [2.3.1](https://github.com/stevearc/aerial.nvim/compare/v2.3.0...v2.3.1) (2024-10-16)


### Bug Fixes

* nav view doesn't force cursor to col 0 ([#403](https://github.com/stevearc/aerial.nvim/issues/403)) ([f6f74a0](https://github.com/stevearc/aerial.nvim/commit/f6f74a04ba72f87c91a0f533d37e03c24518879a))
* telescope extension can customize col widths ([8be4124](https://github.com/stevearc/aerial.nvim/commit/8be41243cd3644eaeeb574c5e80be36fbc022508))
* **telescope:** guard against missing treesitter parser in preview ([603156d](https://github.com/stevearc/aerial.nvim/commit/603156d4fd58963a05f221e76b1a25bc79ed55b0))

## [2.3.0](https://github.com/stevearc/aerial.nvim/compare/v2.2.0...v2.3.0) (2024-09-10)


### Features

* **treesitter:** add XML support ([#405](https://github.com/stevearc/aerial.nvim/issues/405)) ([0a2cf2b](https://github.com/stevearc/aerial.nvim/commit/0a2cf2b120121c50a7c28f021fb2c36f6ba1c533))


### Bug Fixes

* **treesitter:** explicitly set all to false in iter_matches ([#407](https://github.com/stevearc/aerial.nvim/issues/407)) ([3c04b04](https://github.com/stevearc/aerial.nvim/commit/3c04b040a81b800125d7f68f5579892d6bce854d))

## [2.2.0](https://github.com/stevearc/aerial.nvim/compare/v2.1.0...v2.2.0) (2024-08-30)


### Features

* **just:** treesitter support for Just ([#401](https://github.com/stevearc/aerial.nvim/issues/401)) ([bb95e7f](https://github.com/stevearc/aerial.nvim/commit/bb95e7fed7e3d3dc0714722ef6ef57ea1b708a6a))
* **proto:** add treesitter query for grpc in proto filetype ([#404](https://github.com/stevearc/aerial.nvim/issues/404)) ([92f93f4](https://github.com/stevearc/aerial.nvim/commit/92f93f4e155b2135fc47ed2daf8b63f40726b545))
* **starlark:** treesitter support for Starlark ([#402](https://github.com/stevearc/aerial.nvim/issues/402)) ([e585934](https://github.com/stevearc/aerial.nvim/commit/e585934fef8d253dbc5655cff3deb3444e064e6c))
* **telescope:** can provide custom function to format symbols ([#395](https://github.com/stevearc/aerial.nvim/issues/395)) ([eeebf32](https://github.com/stevearc/aerial.nvim/commit/eeebf32fcb365c860248fee785ae5923831bf2ad))
* **toml:** treesitter support for TOML tables ([#396](https://github.com/stevearc/aerial.nvim/issues/396)) ([263beeb](https://github.com/stevearc/aerial.nvim/commit/263beeb92961c15882b7853805f0ae2024f2e903))


### Bug Fixes

* **php:** update treesitter query ([#400](https://github.com/stevearc/aerial.nvim/issues/400)) ([8d2a6c2](https://github.com/stevearc/aerial.nvim/commit/8d2a6c2ffad271b10c91f2c6f6ecef1f9625a9b9))
* **zig:** update queries for new zig treesitter parser ([491e2fc](https://github.com/stevearc/aerial.nvim/commit/491e2fc5640a34dc7f2f6b490670543d17fbc220))

## [2.1.0](https://github.com/stevearc/aerial.nvim/compare/v2.0.0...v2.1.0) (2024-08-10)


### Features

* add support for `mini.icons` ([#383](https://github.com/stevearc/aerial.nvim/issues/383)) ([3d910b2](https://github.com/stevearc/aerial.nvim/commit/3d910b2ba0b8536bb708467690b6685f1783cb19))
* Adds syntax highlighting in the telescope picker ([#386](https://github.com/stevearc/aerial.nvim/issues/386)) ([4e77964](https://github.com/stevearc/aerial.nvim/commit/4e77964569ef47a70f9bb76c668dcfea2d089d5a))


### Bug Fixes

* **ruby:** missing methods in treesitter backend ([#382](https://github.com/stevearc/aerial.nvim/issues/382)) ([e75a3df](https://github.com/stevearc/aerial.nvim/commit/e75a3df2c20b3a98c786f5e61587d74a7a6b61d6))
* warning when closing buffers with the LSP backend in place ([#397](https://github.com/stevearc/aerial.nvim/issues/397)) ([b092d63](https://github.com/stevearc/aerial.nvim/commit/b092d6373d563dc28187a0a340e3daaefc14fc62))

## [2.0.0](https://github.com/stevearc/aerial.nvim/compare/v1.8.0...v2.0.0) (2024-07-15)


### ⚠ BREAKING CHANGES

* drop support for Neovim 0.8 ([#387](https://github.com/stevearc/aerial.nvim/issues/387))

### Code Refactoring

* drop support for Neovim 0.8 ([#387](https://github.com/stevearc/aerial.nvim/issues/387)) ([b309d0d](https://github.com/stevearc/aerial.nvim/commit/b309d0df6b59923a2155f5a8b7ef99777b3311c9))

## [1.8.0](https://github.com/stevearc/aerial.nvim/compare/v1.7.0...v1.8.0) (2024-07-01)


### Features

* highlight parent symbol in Nav UI ([#380](https://github.com/stevearc/aerial.nvim/issues/380)) ([db0af49](https://github.com/stevearc/aerial.nvim/commit/db0af491ff13c18a966ce2f9ac7f5211aec000a7))
* support loongdoc with asciidoc backend ([#377](https://github.com/stevearc/aerial.nvim/issues/377)) ([eb25396](https://github.com/stevearc/aerial.nvim/commit/eb25396dae306cef5b8fffbe9ae98283d2f1c199))


### Bug Fixes

* update tests for vimdoc parser changes ([34cfc01](https://github.com/stevearc/aerial.nvim/commit/34cfc0143d9e0222dba4d1e312ade66214bba848))

## [1.7.0](https://github.com/stevearc/aerial.nvim/compare/v1.6.0...v1.7.0) (2024-05-16)


### Features

* **tsx:** treesitter support for JSX symbols ([#365](https://github.com/stevearc/aerial.nvim/issues/365)) ([7045e7c](https://github.com/stevearc/aerial.nvim/commit/7045e7cb0017d222122a1f6e5795e69754d8b9db))


### Bug Fixes

* attach_mode="global" never allows multiple windows to open ([#369](https://github.com/stevearc/aerial.nvim/issues/369)) ([228fad1](https://github.com/stevearc/aerial.nvim/commit/228fad11393322537d9662c0347f75549a3d6c0a))
* **lualine:** use `sep_icon` in dense mode as well ([#360](https://github.com/stevearc/aerial.nvim/issues/360)) ([218eae4](https://github.com/stevearc/aerial.nvim/commit/218eae4cb7099898b379aa0788c6e3b6a463a23d))
* refactor deprecated methods in neovim 0.10 ([daeee77](https://github.com/stevearc/aerial.nvim/commit/daeee77f3902d170bf7e036bf2a537b14a7ca6e7))

## [1.6.0](https://github.com/stevearc/aerial.nvim/compare/v1.5.0...v1.6.0) (2024-04-16)


### Features

* **backend:** add asciidoc ([#348](https://github.com/stevearc/aerial.nvim/issues/348)) ([c45d567](https://github.com/stevearc/aerial.nvim/commit/c45d5672c870ee8ee6b6feb74d27940a5ddf6748))
* option to enable earial in diff windows ([#355](https://github.com/stevearc/aerial.nvim/issues/355)) ([bdc94c5](https://github.com/stevearc/aerial.nvim/commit/bdc94c53871bf16a4043ab563aa87d4677ab4907)), closes [#354](https://github.com/stevearc/aerial.nvim/issues/354)
* **treesitter:** groovy support ([#351](https://github.com/stevearc/aerial.nvim/issues/351)) ([c8a40b1](https://github.com/stevearc/aerial.nvim/commit/c8a40b12668b0861c9c519f13a8a5f29a1f1ef28))
* **zig:** basic treesitter support for zig. ([#359](https://github.com/stevearc/aerial.nvim/issues/359)) ([5961a1a](https://github.com/stevearc/aerial.nvim/commit/5961a1afc0384845934073d3c7d46ea328d98d89))


### Bug Fixes

* can open aerial in ignored windows ([#352](https://github.com/stevearc/aerial.nvim/issues/352)) ([51a0794](https://github.com/stevearc/aerial.nvim/commit/51a07949abf169b4cad30e14c165ac1ec0ce4e6f))
* check if bufdata.last_win != nil ([#356](https://github.com/stevearc/aerial.nvim/issues/356)) ([24ebaca](https://github.com/stevearc/aerial.nvim/commit/24ebacab5821107c50f628e8e7774f105c08fe9b))
* **julia:** treesitter queries changed upstream ([#362](https://github.com/stevearc/aerial.nvim/issues/362)) ([2f1b897](https://github.com/stevearc/aerial.nvim/commit/2f1b8979d29c30955dbc5a8e4880071df6da1327))
* set lsp.diagnostics_trigger_update=false by default ([993142d](https://github.com/stevearc/aerial.nvim/commit/993142d49274092c64a2d475aa726df3c323949d))

## [1.5.0](https://github.com/stevearc/aerial.nvim/compare/v1.4.0...v1.5.0) (2024-02-03)


### Features

* **telescope:** Save position into jumplist before 'edit' action ([#340](https://github.com/stevearc/aerial.nvim/issues/340)) ([9523ebc](https://github.com/stevearc/aerial.nvim/commit/9523ebc7f0805a4d69a76ef35960a7788a4127af))


### Bug Fixes

* **javascript:** treesitter queries changed upstream ([d21482d](https://github.com/stevearc/aerial.nvim/commit/d21482d3be3228dde594aba31106db428292742c))

## [1.4.0](https://github.com/stevearc/aerial.nvim/compare/v1.3.0...v1.4.0) (2024-01-21)


### Features

* cache aerial tree-sitter queries ([#325](https://github.com/stevearc/aerial.nvim/issues/325)) ([51bdd35](https://github.com/stevearc/aerial.nvim/commit/51bdd35f4f984293d4200e52aeff44f12febc6f2))
* **lualine:** added `sep_icon` option ([#303](https://github.com/stevearc/aerial.nvim/issues/303)) ([9ef83d9](https://github.com/stevearc/aerial.nvim/commit/9ef83d9a7a4ac471d14e608da50b8d91459cae10))
* set scope from node captures and add basic query documentation ([#318](https://github.com/stevearc/aerial.nvim/issues/318)) ([2d169d3](https://github.com/stevearc/aerial.nvim/commit/2d169d349721a94387b9feca5c787296448a623d))
* ship the experimental treesitter selection range ([#279](https://github.com/stevearc/aerial.nvim/issues/279)) ([8e4090b](https://github.com/stevearc/aerial.nvim/commit/8e4090bf9412e24b05823c771cb3956c2ba72981))
* **telescope:** only reverse results when `sorting_strategy = "descending"` ([#307](https://github.com/stevearc/aerial.nvim/issues/307)) ([b811243](https://github.com/stevearc/aerial.nvim/commit/b811243fdc7f624e63ccb6269332aa874afae1e6))
* **treesitter:** ruby queries can set the scope of methods ([#317](https://github.com/stevearc/aerial.nvim/issues/317)) ([3a3baf0](https://github.com/stevearc/aerial.nvim/commit/3a3baf0930444c78d19964fdb401bd3a6a23270f))
* **treesitter:** support for objdump files ([#320](https://github.com/stevearc/aerial.nvim/issues/320)) ([eb301a4](https://github.com/stevearc/aerial.nvim/commit/eb301a4763ba1bb6be4038e9167dc14581bfdc8a))
* **treesitter:** support for snakemake ([#316](https://github.com/stevearc/aerial.nvim/issues/316)) ([c306ffc](https://github.com/stevearc/aerial.nvim/commit/c306ffcf343c737730c119bdf0d7447e7d85e8d2))


### Bug Fixes

* AerialLine highlight has highest priority ([#329](https://github.com/stevearc/aerial.nvim/issues/329)) ([712802e](https://github.com/stevearc/aerial.nvim/commit/712802e73107883a445b36f4197376eb60691b85))
* autoclose floating aerial win on leave ([483d2c8](https://github.com/stevearc/aerial.nvim/commit/483d2c860aed1b857c48d6943e6d2b261653ebfb))
* better error message for refetch_symbols ([#328](https://github.com/stevearc/aerial.nvim/issues/328)) ([8876456](https://github.com/stevearc/aerial.nvim/commit/88764566f96bf900a64b3dcd6d178cfb69b1c8ce))
* **cpp:** add support for declared functions ([#314](https://github.com/stevearc/aerial.nvim/issues/314)) ([340d019](https://github.com/stevearc/aerial.nvim/commit/340d0197d7d30191e31c625c3b2e20912a8e301a))
* default highlights in Neovim 0.9 ([d82a994](https://github.com/stevearc/aerial.nvim/commit/d82a994d66a9c6c700f240498304bd6d68fb33f0))
* delay when using `q` to close ([#311](https://github.com/stevearc/aerial.nvim/issues/311)) ([5f6de33](https://github.com/stevearc/aerial.nvim/commit/5f6de33780ea2f55ad54719eb6bd68ac1026535c))
* don't clear stored data when buffer is unlisted ([edfdcf1](https://github.com/stevearc/aerial.nvim/commit/edfdcf1d45525b063fe4f39ee67e6d51f3dffa11))
* don't jump to top of buffer when autojump = true ([#309](https://github.com/stevearc/aerial.nvim/issues/309)) ([6573d6e](https://github.com/stevearc/aerial.nvim/commit/6573d6ec2166512549f4af7add7b9337fa4a768e))
* Neovim closes on bdelete ([#333](https://github.com/stevearc/aerial.nvim/issues/333)) ([e2e3bc2](https://github.com/stevearc/aerial.nvim/commit/e2e3bc2df4490690ea005395eecdc8eeb30c4def))
* race condition when stopping loading timer ([#331](https://github.com/stevearc/aerial.nvim/issues/331)) ([cf69a43](https://github.com/stevearc/aerial.nvim/commit/cf69a43c086da6db5d93fb4d1a42cf9b278f6a12))
* remove extra double quotes for fzf prompt ([#339](https://github.com/stevearc/aerial.nvim/issues/339)) ([ce9f397](https://github.com/stevearc/aerial.nvim/commit/ce9f397d046b6b2bb2aa3ee89fced937c09e4799))
* **vim treesitter:** support functions with field expression names ([#332](https://github.com/stevearc/aerial.nvim/issues/332)) ([ef08437](https://github.com/stevearc/aerial.nvim/commit/ef08437108247d8805ae388f2699537eac2fd810))

## [1.3.0](https://github.com/stevearc/aerial.nvim/compare/v1.2.0...v1.3.0) (2023-10-12)


### Features

* add lualine separator highlight and optional prefix ([#287](https://github.com/stevearc/aerial.nvim/issues/287)) ([f34defe](https://github.com/stevearc/aerial.nvim/commit/f34defe8f5c2d27f49d53fe0269b87a16f1fb1b9))
* **ts:** add ruby support for ruby operator methods ([#292](https://github.com/stevearc/aerial.nvim/issues/292)) ([fa8c408](https://github.com/stevearc/aerial.nvim/commit/fa8c408b76269a1ce5f17078d4f6cceb8e7e0114))
* **ts:** support for more solidity symbols ([#290](https://github.com/stevearc/aerial.nvim/issues/290)) ([bed048d](https://github.com/stevearc/aerial.nvim/commit/bed048ddef3e7b7fd992bc3a28c413aaa25d63de))


### Bug Fixes

* add guards for unloaded buffers ([#296](https://github.com/stevearc/aerial.nvim/issues/296)) ([d7577c6](https://github.com/stevearc/aerial.nvim/commit/d7577c6bd4714a61f255d685964f6bc0f5ae2474))
* add treesitter support for JS / TS / TSX generator functions ([#289](https://github.com/stevearc/aerial.nvim/issues/289)) ([9bcfbaf](https://github.com/stevearc/aerial.nvim/commit/9bcfbaf7a7d4ad31f234b4a6a1af6bb959838c26))
* aerial ignores diff windows ([#299](https://github.com/stevearc/aerial.nvim/issues/299)) ([c383f45](https://github.com/stevearc/aerial.nvim/commit/c383f45ec061031635488079f52f765c6986b7de))
* missing symbol on navigation shouldn't error ([#295](https://github.com/stevearc/aerial.nvim/issues/295)) ([1175f79](https://github.com/stevearc/aerial.nvim/commit/1175f79bdd1e7800b1b65a7f99a7fe47758652ff))
* queue commands before aerial attaches to avoid dropped inputs ([#301](https://github.com/stevearc/aerial.nvim/issues/301)) ([847a2a3](https://github.com/stevearc/aerial.nvim/commit/847a2a31fb7d2088e41a13ab58a6f7ff97cdc2dd))
* **render:** use EOL extmarks to render AerialLine ([#302](https://github.com/stevearc/aerial.nvim/issues/302)) ([568780e](https://github.com/stevearc/aerial.nvim/commit/568780e7c1d3bedace4d54777871e70be41eb3a7))
* silence errors from moving cursor ([#297](https://github.com/stevearc/aerial.nvim/issues/297)) ([551a2b6](https://github.com/stevearc/aerial.nvim/commit/551a2b679f265917990207e6d8de28018d55f437))
* **ts:** improve ruby handling of singletons and methods ([#293](https://github.com/stevearc/aerial.nvim/issues/293)) ([a2368d1](https://github.com/stevearc/aerial.nvim/commit/a2368d1c4bdb149679fbcbd16a288e5e0bee8156))

## [1.2.0](https://github.com/stevearc/aerial.nvim/compare/v1.1.0...v1.2.0) (2023-08-13)


### Features

* add refetch_symbols API method ([#280](https://github.com/stevearc/aerial.nvim/issues/280)) ([1f15722](https://github.com/stevearc/aerial.nvim/commit/1f1572285725663deb4ec3afece2decabfdca16b))
* experimental support for navigating to symbol names ([#279](https://github.com/stevearc/aerial.nvim/issues/279)) ([e54cae0](https://github.com/stevearc/aerial.nvim/commit/e54cae0df0dc4a368beb705de2f5d2139ce5c062))
* some options can be set on a per-buffer basis ([#280](https://github.com/stevearc/aerial.nvim/issues/280)) ([cd44627](https://github.com/stevearc/aerial.nvim/commit/cd446279f1606c3f44e0e0a8aedbc417f4a9a4d8))
* treesitter supports markdown setext_heading ([#276](https://github.com/stevearc/aerial.nvim/issues/276)) ([de460a4](https://github.com/stevearc/aerial.nvim/commit/de460a4a29491af46eaf2108e6f7534c7b66c4a0))


### Bug Fixes

* default highlight group in nav view is NormalFloat ([#281](https://github.com/stevearc/aerial.nvim/issues/281)) ([2a6498f](https://github.com/stevearc/aerial.nvim/commit/2a6498f4b5f8e52557eadbcd2b3f91da8fe438ca))
* remove debug print statement ([9703f76](https://github.com/stevearc/aerial.nvim/commit/9703f76f3429e1e77a98f2b11b5ee0eb71d65900))
* telescope extension uses selection_range ([#279](https://github.com/stevearc/aerial.nvim/issues/279)) ([bb2cc2f](https://github.com/stevearc/aerial.nvim/commit/bb2cc2fbf0f5be6ff6cd7e467c7c6b02860f3c7b))
* type annotations and type errors ([ffb5fd0](https://github.com/stevearc/aerial.nvim/commit/ffb5fd0aa7fcd5c3f68df38f89af3aa007f76604))

## [1.1.0](https://github.com/stevearc/aerial.nvim/compare/v1.0.0...v1.1.0) (2023-07-11)


### Features

* add new `AerialNormal` highlight as a fallback for all text ([#278](https://github.com/stevearc/aerial.nvim/issues/278)) ([b4eb257](https://github.com/stevearc/aerial.nvim/commit/b4eb257e5422eafbdd577f5b1c9f83ca0359ab7b))
* add solidity treesitter support ([#273](https://github.com/stevearc/aerial.nvim/issues/273)) ([7c2a432](https://github.com/stevearc/aerial.nvim/commit/7c2a432238b9c8e8c526619fa003e658691ea127))
* **elixir:** support parameterless functions ([#277](https://github.com/stevearc/aerial.nvim/issues/277)) ([603ffde](https://github.com/stevearc/aerial.nvim/commit/603ffde23a3834ff6fdafd0db448347337792c10))
* **fzf:** various improvements ([#275](https://github.com/stevearc/aerial.nvim/issues/275)) ([66078ea](https://github.com/stevearc/aerial.nvim/commit/66078ea0fa3589fea8f267672422773ca73ca68d))


### Bug Fixes

* update julia queries for upstream parser changes ([e22facd](https://github.com/stevearc/aerial.nvim/commit/e22facd3a696f4690f888e16ddaba585c8173e4e))

## 1.0.0 (2023-06-24)


### ⚠ BREAKING CHANGES

* ignore win/buffer behavior prevents opening aerial at all ([#204](https://github.com/stevearc/aerial.nvim/issues/204))
* drop support for nvim <0.8
* Link aerial to a source window, not a buffer ([#128](https://github.com/stevearc/aerial.nvim/issues/128))
* split close_behavior into two new config options
* Remove ability to use g:aerial variables to configure
* remove deprecated functions
* manage_folds now defaults to false ([#37](https://github.com/stevearc/aerial.nvim/issues/37))

### Features

* add '?' shortcut to show keymaps (fix [#20](https://github.com/stevearc/aerial.nvim/issues/20)) ([8050cf5](https://github.com/stevearc/aerial.nvim/commit/8050cf5df12f74892b5c7a38c74e58bf114dbbcf))
* add AerialGuide highlight group ([#41](https://github.com/stevearc/aerial.nvim/issues/41)) ([f573bff](https://github.com/stevearc/aerial.nvim/commit/f573bffb0eed26308e82fd2304aaef906a58903b))
* add custom backend to support man pages ([#164](https://github.com/stevearc/aerial.nvim/issues/164)) ([7e03dd4](https://github.com/stevearc/aerial.nvim/commit/7e03dd48472f51ed24184e6818efc0b63e51dca9))
* add disable_max_lines option ([#37](https://github.com/stevearc/aerial.nvim/issues/37)) ([e2a5baf](https://github.com/stevearc/aerial.nvim/commit/e2a5baf45fef7a4ee0f824b58f04e5cc46c716b6))
* add disable_max_size option ([#74](https://github.com/stevearc/aerial.nvim/issues/74)) ([defa94d](https://github.com/stevearc/aerial.nvim/commit/defa94d95569b130dedc3b17d9ba75871ecce5eb))
* add highlight groups to lualine text components ([cb679ac](https://github.com/stevearc/aerial.nvim/commit/cb679ac16d5c2e6c2c204b0542dc369c7b5d59dc))
* add layout.resize_to_content config option ([c4714a6](https://github.com/stevearc/aerial.nvim/commit/c4714a6e37f74629591bf50b51a085314f8abd68))
* add mouse binding to jump to symbol ([#104](https://github.com/stevearc/aerial.nvim/issues/104)) ([2ba3f7a](https://github.com/stevearc/aerial.nvim/commit/2ba3f7afcdd332eaeb9316ed84d08c807556b6b2))
* add resession extension ([f7d6ca8](https://github.com/stevearc/aerial.nvim/commit/f7d6ca898b32f00c29037d399ab6bba77b2a2ad9))
* add show_guides config option ([#41](https://github.com/stevearc/aerial.nvim/issues/41)) ([b17c9d2](https://github.com/stevearc/aerial.nvim/commit/b17c9d2f65bafc57df2b7f0b7c2f3f1e0a4ff7a3))
* add support for org files ([1e698f3](https://github.com/stevearc/aerial.nvim/commit/1e698f36fa4e7216688954ae2b22bee483720482))
* add support for vim help files ([#164](https://github.com/stevearc/aerial.nvim/issues/164)) ([817be1d](https://github.com/stevearc/aerial.nvim/commit/817be1d211be9ff8acf6eac4d205b1a3b4dbffed))
* add symbol ranges for treesitter and markdown ([#52](https://github.com/stevearc/aerial.nvim/issues/52)) ([9135045](https://github.com/stevearc/aerial.nvim/commit/91350456c176fe5ef72e342dd3a75f726805454d))
* add treesitter support for bash ([1f5a48b](https://github.com/stevearc/aerial.nvim/commit/1f5a48b06486e7244d0536b2bf439041367916f2))
* add treesitter support for julia ([#42](https://github.com/stevearc/aerial.nvim/issues/42)) ([0788ae5](https://github.com/stevearc/aerial.nvim/commit/0788ae5abfe104d65ea598d1427099c1695e20b7))
* add treesitter support for markdown ([d9436f2](https://github.com/stevearc/aerial.nvim/commit/d9436f2be9dda2ba2bd469243d69479876561275))
* AerialClose will close any open aerial window ([#95](https://github.com/stevearc/aerial.nvim/issues/95)) ([f0bd36b](https://github.com/stevearc/aerial.nvim/commit/f0bd36b3339eec483c840789b0350a8a0968668a))
* allow customization of guides ([#41](https://github.com/stevearc/aerial.nvim/issues/41)) ([6a425ba](https://github.com/stevearc/aerial.nvim/commit/6a425ba8b2d4e111b738df33856091a7450c0d8b))
* allow manage_folds to be a filetype map ([88b5192](https://github.com/stevearc/aerial.nvim/commit/88b519239940079b57d7077d728a2b0897b00923))
* autojump config option ([#244](https://github.com/stevearc/aerial.nvim/issues/244)) ([50ee951](https://github.com/stevearc/aerial.nvim/commit/50ee9515f35104ddc2f1a28480beeea1357cf355))
* can open aerial in a floating window (fix [#23](https://github.com/stevearc/aerial.nvim/issues/23)) ([568584c](https://github.com/stevearc/aerial.nvim/commit/568584ce5471fca84045a248e7c7d0e40dc28881))
* center the current symbol after opening aerial ([#165](https://github.com/stevearc/aerial.nvim/issues/165)) ([26f0320](https://github.com/stevearc/aerial.nvim/commit/26f0320e959b786dea8513c3be0e46c69e68efc0))
* choose better default icons ([1104a9f](https://github.com/stevearc/aerial.nvim/commit/1104a9f5f495ccb9bc30d6f2a7c2ceb760f254a7))
* color lualine icons ([#155](https://github.com/stevearc/aerial.nvim/issues/155)) ([6f1b28b](https://github.com/stevearc/aerial.nvim/commit/6f1b28b549147c2f9e09de16869fcc34cf076253))
* config callback for first symbols ([c08aeea](https://github.com/stevearc/aerial.nvim/commit/c08aeea399ffe14a36ac9c5a85b73c5cb6471470))
* configurable update events ([#58](https://github.com/stevearc/aerial.nvim/issues/58)) ([96f1011](https://github.com/stevearc/aerial.nvim/commit/96f1011ccda2d918ee2a6368ffcc235316530ab6))
* different guide hl group per-level ([#41](https://github.com/stevearc/aerial.nvim/issues/41)) ([0c5c346](https://github.com/stevearc/aerial.nvim/commit/0c5c346e8892b69e1e9b20cf19a5eadf84d1c8c6))
* display ignore status in AerialInfo ([a562b9d](https://github.com/stevearc/aerial.nvim/commit/a562b9d99f5d87ed645fcd6256746619bcae2dc8))
* expose window-local options in config ([#176](https://github.com/stevearc/aerial.nvim/issues/176)) ([1eb6d23](https://github.com/stevearc/aerial.nvim/commit/1eb6d23742aca676f5de1cc123b0045eaa12ca48))
* highlight group for non-current split line ([537fe60](https://github.com/stevearc/aerial.nvim/commit/537fe602dff9c10bbe350cb185a224c7acf61fd5))
* highlight_closest config option ([#52](https://github.com/stevearc/aerial.nvim/issues/52)) ([5ba5985](https://github.com/stevearc/aerial.nvim/commit/5ba5985306fcc548a26f2e38ac9e458778a37cab))
* icons can be defined as per-filetype map ([#108](https://github.com/stevearc/aerial.nvim/issues/108)) ([ae97872](https://github.com/stevearc/aerial.nvim/commit/ae9787240c4f97e28fb8c5b8c6ba96ee6fcd80d1))
* include receiver in golang methods ([#194](https://github.com/stevearc/aerial.nvim/issues/194)) ([661d0ad](https://github.com/stevearc/aerial.nvim/commit/661d0adaa43a20fb692e01261b6afb0841318617))
* **java:** add support for constructors ([8b8129e](https://github.com/stevearc/aerial.nvim/commit/8b8129e7306449dbc9fefb246f55ac3ee88d92a5))
* jest support for tsx ([#47](https://github.com/stevearc/aerial.nvim/issues/47)) ([2b71abb](https://github.com/stevearc/aerial.nvim/commit/2b71abbcc3c6aac93715b7a9761644076c030286))
* jest support for typescript ([#47](https://github.com/stevearc/aerial.nvim/issues/47)) ([960cf86](https://github.com/stevearc/aerial.nvim/commit/960cf86d9a2317dc9c0d9e0e58f84945383a3050))
* keymap table accepts all vim.keymap.set opts ([#179](https://github.com/stevearc/aerial.nvim/issues/179)) ([5dd0904](https://github.com/stevearc/aerial.nvim/commit/5dd090432e9672e09ecdbdd83b6dd769bac34298))
* lazier loading for third party plugins ([4c6f8aa](https://github.com/stevearc/aerial.nvim/commit/4c6f8aaa043bda67497c2c3cfb0700af57b11d08))
* lazy loading technically works ([20618f2](https://github.com/stevearc/aerial.nvim/commit/20618f26ad62c58770ea85ef698100569c7b892f))
* **lsp:** exact-match support for lualine component ([#52](https://github.com/stevearc/aerial.nvim/issues/52)) ([f19e748](https://github.com/stevearc/aerial.nvim/commit/f19e7484b45ad301441bf95abb68fc9c8614bb16))
* **lsp:** watch buffer changes when diagnostics_trigger_update = false ([886d900](https://github.com/stevearc/aerial.nvim/commit/886d90074d15093ef0d87a4f8826b6a9c706c6f0))
* manage_folds now defaults to false ([#37](https://github.com/stevearc/aerial.nvim/issues/37)) ([240888e](https://github.com/stevearc/aerial.nvim/commit/240888e007fd53ef462ee445e4d107e93e570428))
* map g? to show aerial buffer keymaps ([3c8a70c](https://github.com/stevearc/aerial.nvim/commit/3c8a70c88c46b468262d2a98a27d48c4abd818b3))
* nav view can preview symbol in rightmost column ([#235](https://github.com/stevearc/aerial.nvim/issues/235)) ([055d220](https://github.com/stevearc/aerial.nvim/commit/055d2209ad04b032b883f66b907f1dd50bcde01b))
* New commands for opening/closing multiple windows ([#100](https://github.com/stevearc/aerial.nvim/issues/100)) ([19e7391](https://github.com/stevearc/aerial.nvim/commit/19e739139283c8ac5e2c147f870d2a038496688e))
* new highlight_on_hover option ([#65](https://github.com/stevearc/aerial.nvim/issues/65)) ([8b27c45](https://github.com/stevearc/aerial.nvim/commit/8b27c45f71feeba660bb4344c543745746120706))
* new navigation view ([#235](https://github.com/stevearc/aerial.nvim/issues/235)) ([4b725dc](https://github.com/stevearc/aerial.nvim/commit/4b725dc8e59f6e43fff16912841bfc170d034b7d))
* new option layout.preserve_equality to keep window sizes equal ([#192](https://github.com/stevearc/aerial.nvim/issues/192)) ([65ca35c](https://github.com/stevearc/aerial.nvim/commit/65ca35c66cab9d854d17cb41c87490859775e05b))
* open_in_win to open aerial in an existing window ([#248](https://github.com/stevearc/aerial.nvim/issues/248)) ([d8f2699](https://github.com/stevearc/aerial.nvim/commit/d8f2699f7ae0e5eb62424d7b2ad80ce30179ee92))
* pass is_collapsed to get_highlight config function ([#257](https://github.com/stevearc/aerial.nvim/issues/257)) ([b154c0c](https://github.com/stevearc/aerial.nvim/commit/b154c0cbe096a7479a89ed32175831a97b0c5a1a))
* priority ranking for LSP clients ([#222](https://github.com/stevearc/aerial.nvim/issues/222)) ([7af6f81](https://github.com/stevearc/aerial.nvim/commit/7af6f812e41a28b19ddc1f7709374d4d765f8c78))
* **queries:** add basic yaml support ([c29e53a](https://github.com/stevearc/aerial.nvim/commit/c29e53a1b8199847d4d54a708c8ec0c0a9ab4338))
* **queries:** add norg support ([cefd62b](https://github.com/stevearc/aerial.nvim/commit/cefd62bda3e63c9b7371fa0fbae5910cf8b05087))
* **queries:** add teal support ([f645a4f](https://github.com/stevearc/aerial.nvim/commit/f645a4fe1ad8d48a18f76569c177e60e3266b47f))
* race symbol backends on first fetch ([#177](https://github.com/stevearc/aerial.nvim/issues/177)) ([45de4de](https://github.com/stevearc/aerial.nvim/commit/45de4de76f1bb90f956281b4699df9b058417784))
* return line and column number for each symbol in get_location API ([d5b405e](https://github.com/stevearc/aerial.nvim/commit/d5b405e79b0f0aadda3265cfe1e75651f05e2b0f))
* show hierarchy of symbols in telescope picker ([a30aa79](https://github.com/stevearc/aerial.nvim/commit/a30aa7991689545f4ee2259c4f44466d15952672))
* support more floating window layouts ([#60](https://github.com/stevearc/aerial.nvim/issues/60)) ([0ae1984](https://github.com/stevearc/aerial.nvim/commit/0ae198421064e1971b5d5cb629f43adeb55c04d2))
* telescope selector uses current symbol for default_selection_index ([#161](https://github.com/stevearc/aerial.nvim/issues/161)) ([89a61da](https://github.com/stevearc/aerial.nvim/commit/89a61daba8da7c7cebc36fe9ddfeb0b5f8663e50))
* telescope show_nesting opt can be a filetype map ([c5436fd](https://github.com/stevearc/aerial.nvim/commit/c5436fdafd63dd4d0fe61987dd5aa2a821a05874))
* tree can set collapse level ([c892e2e](https://github.com/stevearc/aerial.nvim/commit/c892e2ea82a3d420b6425eb3d5137b8f4ca1d687))
* tree mutations take a bufnr ([b247ef5](https://github.com/stevearc/aerial.nvim/commit/b247ef50c7e5c5e5a78fce45880c1a4db9150667))
* treesitter support for latex ([#137](https://github.com/stevearc/aerial.nvim/issues/137)) ([1c666a6](https://github.com/stevearc/aerial.nvim/commit/1c666a62a27d65118354ba70679bc44d08f90715))
* **ts:** Add support for elixir ([897d4bd](https://github.com/stevearc/aerial.nvim/commit/897d4bd85279ac73cc9c8ed20ace203efb974b6a))
* **ts:** treesitter supports variables in python ([#227](https://github.com/stevearc/aerial.nvim/issues/227)) ([1e0c546](https://github.com/stevearc/aerial.nvim/commit/1e0c546c2c451737c769d601e3935ef9267d25dd))
* update events can be a table ([#58](https://github.com/stevearc/aerial.nvim/issues/58)) ([0a229de](https://github.com/stevearc/aerial.nvim/commit/0a229de4633a51548cb7257a116ea48dd4dd38c2))


### Bug Fixes

* add config option for LSP update delay ([8681b03](https://github.com/stevearc/aerial.nvim/commit/8681b03be271d1bd576ddbf707ece76614d4e9b1))
* add interface type to golang treesitter backend ([#180](https://github.com/stevearc/aerial.nvim/issues/180)) ([480bf14](https://github.com/stevearc/aerial.nvim/commit/480bf143325171c1f4003f6b3e82ade98b5f9bc3))
* add Module to the default filter_kind list ([92c205c](https://github.com/stevearc/aerial.nvim/commit/92c205c507b8ada136ed7f4893a8a3851d6b017e))
* add nil check to source window id ([9e0b28a](https://github.com/stevearc/aerial.nvim/commit/9e0b28a1a92062473964d9bb5aeca05c8f6dfd7f))
* adjust window width calculation if 'number' or 'relativenumber' ([#32](https://github.com/stevearc/aerial.nvim/issues/32)) ([a0a46ed](https://github.com/stevearc/aerial.nvim/commit/a0a46ed74f4666efb5b3dfd48c9708ec8e09809b))
* aerial split starts at size 1 ([3c39fb3](https://github.com/stevearc/aerial.nvim/commit/3c39fb38a59b7de4b8c5b8211113771fdd791d97))
* aerial tree collapse state shouldn't affect get_location ([#163](https://github.com/stevearc/aerial.nvim/issues/163)) ([c248731](https://github.com/stevearc/aerial.nvim/commit/c2487319c083bc1da3aecf21e054c6cf1bbda9b3))
* aerial.prev with no arguments ([93c6ceb](https://github.com/stevearc/aerial.nvim/commit/93c6cebee668e202328a9b39f6d2866a328c01c9))
* AerialClose closes other wins if buf has no symbols ([#95](https://github.com/stevearc/aerial.nvim/issues/95)) ([f1dfb0a](https://github.com/stevearc/aerial.nvim/commit/f1dfb0a05cd87f21175f33b3c8f4fbe4b1d77f18))
* always close keymap help window ([17f97fd](https://github.com/stevearc/aerial.nvim/commit/17f97fd2ca8acd055108c91c0c6406d0fb395396))
* apply kind filter after treesitter postprocessing ([b947110](https://github.com/stevearc/aerial.nvim/commit/b947110e9b009414acd80c78d56379a58deee2e4))
* attach to first file when lazy-loaded ([#64](https://github.com/stevearc/aerial.nvim/issues/64)) ([d864b46](https://github.com/stevearc/aerial.nvim/commit/d864b463bca824ebbdf2b17a0ac046955c007b2b))
* attempt to fix stack overflow ([#36](https://github.com/stevearc/aerial.nvim/issues/36)) ([a7930db](https://github.com/stevearc/aerial.nvim/commit/a7930dbe7517c82b68464b6a2b363825c3ff4977))
* bad method names from refactor ([05fff54](https://github.com/stevearc/aerial.nvim/commit/05fff54b2fe315d0f3a00dc1bf0196b61ffcdf2e))
* broken tests from neovim update ([6e9e965](https://github.com/stevearc/aerial.nvim/commit/6e9e965353afb6834b7bc590a8a572b82fdc86cc))
* buffer mismatch in LSP symbols call ([#130](https://github.com/stevearc/aerial.nvim/issues/130)) ([551c43c](https://github.com/stevearc/aerial.nvim/commit/551c43c70ae793cd2bbbaa1c45b72c938f579567))
* bug about splitkeep (fix [#199](https://github.com/stevearc/aerial.nvim/issues/199)) ([c28ce50](https://github.com/stevearc/aerial.nvim/commit/c28ce509925be66ad82706470bc0554e16756404))
* C++ struct variables appear as symbols ([#153](https://github.com/stevearc/aerial.nvim/issues/153)) ([f1e0f0e](https://github.com/stevearc/aerial.nvim/commit/f1e0f0ea3b50aa929d003617e3cef1776f5f324d))
* catch all splitkeep access errors ([4c3ff75](https://github.com/stevearc/aerial.nvim/commit/4c3ff7554d4853b5b6372c9c4a5077076977ceb7))
* changing foldlevel updates tree correctly ([#120](https://github.com/stevearc/aerial.nvim/issues/120)) ([bd29cd1](https://github.com/stevearc/aerial.nvim/commit/bd29cd16218767cc8ac93d47d077cd4d19b0c43a))
* check validity of buffer in deferred callbacks ([4f36dee](https://github.com/stevearc/aerial.nvim/commit/4f36deee7331a21ee32f0730aa0ebad09e38c570))
* close aerial when it's the last window ([#90](https://github.com/stevearc/aerial.nvim/issues/90)) ([8d2ef96](https://github.com/stevearc/aerial.nvim/commit/8d2ef96e44768250a652826c6586005f40eeac7f))
* close_on_select applies to split/vsplit jumps ([#191](https://github.com/stevearc/aerial.nvim/issues/191)) ([5392fc1](https://github.com/stevearc/aerial.nvim/commit/5392fc192a4becbaaf57f7eadfe7780b1577ed1b))
* close_on_select will no longer affect preview ([4c588bd](https://github.com/stevearc/aerial.nvim/commit/4c588bd12567b500838d33d36336f146fa43b0b9))
* correctly fetch splitkeep option value ([4428a47](https://github.com/stevearc/aerial.nvim/commit/4428a478e70f6a6b52e86d16ced677020267f409))
* crash in lualine component when dense = true ([fb6bbaa](https://github.com/stevearc/aerial.nvim/commit/fb6bbaaceebd2172112dc4ebccc88ee4084d930c))
* crash when no symbols in aerial win ([3a482fe](https://github.com/stevearc/aerial.nvim/commit/3a482fe4ac035af6b3849cb6b7c761973f5ff70f))
* cursor doesn't jump when opening tree ([e5a1965](https://github.com/stevearc/aerial.nvim/commit/e5a1965999c32cb4be2e84f226afda2cb69bbab8))
* delay require of lspkind and nvim-web-devicons ([b9cde18](https://github.com/stevearc/aerial.nvim/commit/b9cde181c39a8aad139a559d6458a2b544c4e552))
* deprecated treesitter API in nvim nightly ([a6b86fd](https://github.com/stevearc/aerial.nvim/commit/a6b86fd357f184ad9f146245f8d34c9df0f424fa))
* deprecation message for up commands ([7339efd](https://github.com/stevearc/aerial.nvim/commit/7339efd9ab61e0ab1d79a8c59995b93405d3c8d9))
* disable all resizing when resize_to_content = false ([075b0fa](https://github.com/stevearc/aerial.nvim/commit/075b0fac9066d2c272ae800c63f23753536564c8))
* display symbols that occupy the same location ([#132](https://github.com/stevearc/aerial.nvim/issues/132)) ([7a8da21](https://github.com/stevearc/aerial.nvim/commit/7a8da219c8109cee0aa15d437959165d50a4130a))
* do not open_automatic in unsupported buffers ([#185](https://github.com/stevearc/aerial.nvim/issues/185)) ([047e19d](https://github.com/stevearc/aerial.nvim/commit/047e19de0421a6c3f2c0954b950cf8f53728c4c4))
* don't center cursor-relative float ([#62](https://github.com/stevearc/aerial.nvim/issues/62)) ([37802e7](https://github.com/stevearc/aerial.nvim/commit/37802e72263f1592575ec1133969890b703e70a7))
* don't collapse uncollapsable leaf nodes ([#268](https://github.com/stevearc/aerial.nvim/issues/268)) ([c30fb2c](https://github.com/stevearc/aerial.nvim/commit/c30fb2c9bd09592351eed676f4c20e7a6411020e))
* don't default to lazy initialization if open_automatic = true ([#203](https://github.com/stevearc/aerial.nvim/issues/203)) ([ea86cd2](https://github.com/stevearc/aerial.nvim/commit/ea86cd2b05081873d3ae12fcf2aa77b59b7f11fd))
* don't ignore help buftypes by default ([#204](https://github.com/stevearc/aerial.nvim/issues/204)) ([7acdd61](https://github.com/stevearc/aerial.nvim/commit/7acdd616eebb1e96ddcd5966da85bf466264004f))
* don't set up aerial win/buf more than once ([#166](https://github.com/stevearc/aerial.nvim/issues/166)) ([e3dbe2b](https://github.com/stevearc/aerial.nvim/commit/e3dbe2b2928561bf76e23a3b049b783abb42f736))
* enforce treesitter backend uses LSP SymbolKind values ([#219](https://github.com/stevearc/aerial.nvim/issues/219)) ([06c6b4c](https://github.com/stevearc/aerial.nvim/commit/06c6b4c8eba1a903d1f972ec06ff0c4da26072df))
* error in dev version of nvim 0.6.0 ([dffcc8e](https://github.com/stevearc/aerial.nvim/commit/dffcc8ecd1620e897afd0550b47ffbb71d719e5a))
* error on missing splitkeep option ([#202](https://github.com/stevearc/aerial.nvim/issues/202)) ([92914ca](https://github.com/stevearc/aerial.nvim/commit/92914ca691755f111420224e1800168c4371059c))
* error opening aerial window (fixes [#35](https://github.com/stevearc/aerial.nvim/issues/35)) ([9015ef5](https://github.com/stevearc/aerial.nvim/commit/9015ef5ce934929a98f9a629b2d9ada4af25b8e2))
* error when aerial is open on unsupported window ([767181b](https://github.com/stevearc/aerial.nvim/commit/767181b649852fa34865366508b79c329c357bc8))
* error when centering aerial symbol in view ([#165](https://github.com/stevearc/aerial.nvim/issues/165)) ([6a8fd67](https://github.com/stevearc/aerial.nvim/commit/6a8fd67801649e1d7105328d3a93df6bea1d3dbe))
* error when opening aerial as float ([#45](https://github.com/stevearc/aerial.nvim/issues/45)) ([8454dee](https://github.com/stevearc/aerial.nvim/commit/8454deef149b2e1a450e0f80c81f8d0bca1e17fe))
* error when opening aerial in float ([#133](https://github.com/stevearc/aerial.nvim/issues/133)) ([9e0bbcd](https://github.com/stevearc/aerial.nvim/commit/9e0bbcde994881942030d6456b743cc199ceaacf))
* error when opening float using LSP backend ([1c78147](https://github.com/stevearc/aerial.nvim/commit/1c78147a2aea5b00d8291b94158591dfa435ebaf))
* error when opening nav view on file with no symbols ([#256](https://github.com/stevearc/aerial.nvim/issues/256)) ([30316db](https://github.com/stevearc/aerial.nvim/commit/30316db63d816993b70621e8248437251d57076b))
* error when switching buffers ([8d0915b](https://github.com/stevearc/aerial.nvim/commit/8d0915b1f8257950092df3f47e40ac2abd7b3725))
* error with close_automatic_events = 'unsupported' ([#175](https://github.com/stevearc/aerial.nvim/issues/175)) ([6b1e97e](https://github.com/stevearc/aerial.nvim/commit/6b1e97efb7a22c2d4f3c255da8d91456f183444d))
* escape % in lualine component ([937a4af](https://github.com/stevearc/aerial.nvim/commit/937a4af150def677bbd816d7036f5dce5f561a46))
* failing tests ([423dcc0](https://github.com/stevearc/aerial.nvim/commit/423dcc065662c94107fb0844ba5f9aa769c2565e))
* foldexpr bugs with nested structures ([32edfc1](https://github.com/stevearc/aerial.nvim/commit/32edfc147dd0389663188e5f0b1eda9102615d61))
* guard against invalid buffers ([#207](https://github.com/stevearc/aerial.nvim/issues/207)) ([e2b6cd0](https://github.com/stevearc/aerial.nvim/commit/e2b6cd07b45f8457ea183d16e483fdac3581b04f))
* guard against invalid window ID errors ([#152](https://github.com/stevearc/aerial.nvim/issues/152)) ([b3f8df4](https://github.com/stevearc/aerial.nvim/commit/b3f8df4c7a75ac9b9e4290df9e1b36eacf087c9b))
* guides don't pick up italics from Comment group ([#182](https://github.com/stevearc/aerial.nvim/issues/182)) ([d22daba](https://github.com/stevearc/aerial.nvim/commit/d22daba7af04ffa0363e8fbb0e1c06eab79c647d))
* hack around LSP server not reporting symbol name ([#126](https://github.com/stevearc/aerial.nvim/issues/126)) ([86b8341](https://github.com/stevearc/aerial.nvim/commit/86b8341bb8c58ece7e7f3f9b2d0310f4a328ab21))
* help parser has been renamed to vimdoc ([bc2bc8b](https://github.com/stevearc/aerial.nvim/commit/bc2bc8b5d0daacc7ecb14d4dbe3c2516dbb6945e))
* hide noisy listchars by default ([#46](https://github.com/stevearc/aerial.nvim/issues/46)) ([d6810ff](https://github.com/stevearc/aerial.nvim/commit/d6810ffdac2ab145f8337585ee4c1ed209993f5b))
* icons not respected in config (fix [#27](https://github.com/stevearc/aerial.nvim/issues/27)) ([299570d](https://github.com/stevearc/aerial.nvim/commit/299570d8e5ad76e0f500ee4f0920dfe3f32844d5))
* ignore win/buffer behavior prevents opening aerial at all ([#204](https://github.com/stevearc/aerial.nvim/issues/204)) ([b1e6c7d](https://github.com/stevearc/aerial.nvim/commit/b1e6c7d94b293f682cfb474333838094f321b5e7))
* improper window behavior when attach_mode = 'global' ([#185](https://github.com/stevearc/aerial.nvim/issues/185)) ([e161ad5](https://github.com/stevearc/aerial.nvim/commit/e161ad5f4712428d923f9a8603601344b63a9ab9))
* improve code folding logic; support zm/zr ([3b3ed01](https://github.com/stevearc/aerial.nvim/commit/3b3ed01a7acfcdad7e5b4daead4a681d00c0ec5c))
* include buffer in LSP no support message ([#236](https://github.com/stevearc/aerial.nvim/issues/236)) ([00cac8e](https://github.com/stevearc/aerial.nvim/commit/00cac8e96f932dca8f559849cbea3f0812621d0d))
* incorrect folding for top level tree entries ([#178](https://github.com/stevearc/aerial.nvim/issues/178)) ([bf80cba](https://github.com/stevearc/aerial.nvim/commit/bf80cbacc54fc85dd8330e0974e6c37fa3da3737))
* invalid buffer error ([#38](https://github.com/stevearc/aerial.nvim/issues/38)) ([81f002f](https://github.com/stevearc/aerial.nvim/commit/81f002fcf85711600febc9ec36430a01fba717ed))
* invalid buffer id ([#170](https://github.com/stevearc/aerial.nvim/issues/170)) ([31c2304](https://github.com/stevearc/aerial.nvim/commit/31c2304397c73d004b8b621f4afbacbabf5eea86))
* invalid winid number ([#61](https://github.com/stevearc/aerial.nvim/issues/61)) ([ca7ef2d](https://github.com/stevearc/aerial.nvim/commit/ca7ef2db514419c39c55a4a8ab8b2e8e5e672e1d))
* julia treesitter queries for updated julia parser ([3423358](https://github.com/stevearc/aerial.nvim/commit/342335889518ceef465d4a38299d80841eaf6daa))
* lazy loading doesn't work well with LSP backend ([#173](https://github.com/stevearc/aerial.nvim/issues/173)) ([d453a73](https://github.com/stevearc/aerial.nvim/commit/d453a73279211654f242e86fb6df0f4fca223317))
* limitations with custom floating window options ([#107](https://github.com/stevearc/aerial.nvim/issues/107)) ([5d93978](https://github.com/stevearc/aerial.nvim/commit/5d939786fa22cc4377fcc9678630e47b4db0a9d3))
* loading status when first opening aerial win ([0f65dc4](https://github.com/stevearc/aerial.nvim/commit/0f65dc41e23c713c13c9bfe031b35bf96d7f006a))
* LSP symbol gathering when SelectionRange is missing ([#136](https://github.com/stevearc/aerial.nvim/issues/136)) ([efc597c](https://github.com/stevearc/aerial.nvim/commit/efc597cc70c36ecd2be54256190a0f2c32cde728))
* LSP synchronous symbol fetch when buffer has multiple clients ([#215](https://github.com/stevearc/aerial.nvim/issues/215)) ([7f09d0d](https://github.com/stevearc/aerial.nvim/commit/7f09d0d00360e491cb063ceb56aac9b2d6e5a911))
* **lsp:** close_behavior='auto' shouldn't close aerial when switching buffers ([922155d](https://github.com/stevearc/aerial.nvim/commit/922155d70edf28249d9f8c6d1e4f8b53c4fe6396))
* **lsp:** remove call to deprecated vim.lsp.diagnostic (fixes [#31](https://github.com/stevearc/aerial.nvim/issues/31)) ([e02059b](https://github.com/stevearc/aerial.nvim/commit/e02059bc1a88bc935808ed20ab4a19772a0eff9e))
* luacheck warning ([df0cce6](https://github.com/stevearc/aerial.nvim/commit/df0cce65062a95dac3250056ef9e5dd8177d474c))
* lualine separators use default hl group ([#171](https://github.com/stevearc/aerial.nvim/issues/171)) ([56282c9](https://github.com/stevearc/aerial.nvim/commit/56282c9d52307e626e7915f1cf0f34f16c8ac5d6))
* man pages shouldn't be ignored by default ([ba60a0b](https://github.com/stevearc/aerial.nvim/commit/ba60a0b1f55a8f0407f653492fbdadab3684125d))
* migrate deprecated ts_util.get_node_text call ([#84](https://github.com/stevearc/aerial.nvim/issues/84)) ([1bd3cf1](https://github.com/stevearc/aerial.nvim/commit/1bd3cf16bb874538e0c37f80a46ab62aa9e09eb0))
* name captures respect offset metadata ([#247](https://github.com/stevearc/aerial.nvim/issues/247)) ([3721075](https://github.com/stevearc/aerial.nvim/commit/3721075a6903859c4936bdc7e5a4c345f93d3aac))
* navigating to invalid buffer ([#195](https://github.com/stevearc/aerial.nvim/issues/195)) ([7e2fef6](https://github.com/stevearc/aerial.nvim/commit/7e2fef6ec501a3fe8bc6c4051b3a1014dc098a06))
* navigation issues with volar ([#183](https://github.com/stevearc/aerial.nvim/issues/183)) ([4b42ddb](https://github.com/stevearc/aerial.nvim/commit/4b42ddbd453caec3b12541af80e498a02d47cf20))
* navigation tests ([389a644](https://github.com/stevearc/aerial.nvim/commit/389a644e147a3b15af4606ebad04133c42d3a0d5))
* nil winid ([#61](https://github.com/stevearc/aerial.nvim/issues/61)) ([f41a715](https://github.com/stevearc/aerial.nvim/commit/f41a715d14641c063d5fa7c43372d8bf3910b76e))
* no LSP client found messages ([#249](https://github.com/stevearc/aerial.nvim/issues/249)) ([72813e6](https://github.com/stevearc/aerial.nvim/commit/72813e602039266c37e78075ba7a30e45fbbf52f))
* only allow collapsing leaf nodes if link_tree_to_folds = true ([#257](https://github.com/stevearc/aerial.nvim/issues/257)) ([5c5b355](https://github.com/stevearc/aerial.nvim/commit/5c5b355f29664577738d8843e948d16ff17afe65))
* only attach treesitter backend if we have the queries ([5752afb](https://github.com/stevearc/aerial.nvim/commit/5752afb3a14c73b594c540a788decddff37941aa))
* only set aerial filetype when we are in the aerial buffer ([737d65a](https://github.com/stevearc/aerial.nvim/commit/737d65a75aa12a7365b0bd8d597664ee4271a3b1))
* option filetype maps when default value is false ([#158](https://github.com/stevearc/aerial.nvim/issues/158)) ([e0215f9](https://github.com/stevearc/aerial.nvim/commit/e0215f9dcf55e917f547ad2c688be6fe67a5926d))
* overriding listchars defaults sometimes fails ([#46](https://github.com/stevearc/aerial.nvim/issues/46)) ([ee3eab5](https://github.com/stevearc/aerial.nvim/commit/ee3eab57a29dd4ccfc7d5c43ede114c621546750))
* pass bufnr to backend fetch_symbols method ([#78](https://github.com/stevearc/aerial.nvim/issues/78)) ([8f34bfd](https://github.com/stevearc/aerial.nvim/commit/8f34bfd165b0815c05c9df164ba2c06bd9f03eef))
* pass bufnr to LSP callback ([#110](https://github.com/stevearc/aerial.nvim/issues/110)) ([95a6f71](https://github.com/stevearc/aerial.nvim/commit/95a6f71af6cad4cad8f2f3873ad012c8ba754b4f))
* placement_editor_edge = true creates full-height split ([369d32e](https://github.com/stevearc/aerial.nvim/commit/369d32eef90b071829ff4bbf2010f2d207ca33ca))
* position not highlighted when opening float ([351b969](https://github.com/stevearc/aerial.nvim/commit/351b9693f1e0af0b0bbb05a8aef294bce1365e3c))
* possible race condition in LspDetach ([85fe530](https://github.com/stevearc/aerial.nvim/commit/85fe53058c84528c0027021913518a656f136830))
* prevent error when symbols have newline ([a13fcd5](https://github.com/stevearc/aerial.nvim/commit/a13fcd5e921c88eaa0a6590d94d8e5694400ef3f))
* properly clean up symbols when buffers are deleted ([71a936e](https://github.com/stevearc/aerial.nvim/commit/71a936ee41e3e900fc8e23c308674770e72c8a2b))
* provide more info when aerial not supported ([#186](https://github.com/stevearc/aerial.nvim/issues/186)) ([e0f744c](https://github.com/stevearc/aerial.nvim/commit/e0f744c9c3c2b230a717ad9036a03a776c492be6))
* reduce default disable_max_size 10MB-&gt;2MB ([59d257f](https://github.com/stevearc/aerial.nvim/commit/59d257fe8d41c387cae37537f26df0eac84db8a8))
* remove deprecation warnings from tests ([9e744c7](https://github.com/stevearc/aerial.nvim/commit/9e744c7e8887b94862047165d1557fe58b823bb5))
* remove duplicate LSP client checking logic ([#236](https://github.com/stevearc/aerial.nvim/issues/236)) ([24fe657](https://github.com/stevearc/aerial.nvim/commit/24fe657357320cab076eb88d17aae64d014fae38))
* remove newlines from symbol names ([#73](https://github.com/stevearc/aerial.nvim/issues/73)) ([0f22463](https://github.com/stevearc/aerial.nvim/commit/0f22463cc1616c0ae7a5a4ad4d81f133035e61c4))
* remove unnecessary window resizing ([#53](https://github.com/stevearc/aerial.nvim/issues/53)) ([8e7911f](https://github.com/stevearc/aerial.nvim/commit/8e7911febdf988f31fc4573c3df483117328069d))
* remove unused variable ([008caa5](https://github.com/stevearc/aerial.nvim/commit/008caa510d55c442b6a90ab035475052456c9d66))
* resize windows after opening aerial ([#98](https://github.com/stevearc/aerial.nvim/issues/98)) ([eba03e1](https://github.com/stevearc/aerial.nvim/commit/eba03e1cddae498f80ac93d7e0e60c97ef7ec42f))
* return cursor to source window when closing aerial ([#241](https://github.com/stevearc/aerial.nvim/issues/241)) ([a2beef7](https://github.com/stevearc/aerial.nvim/commit/a2beef7cd6b93c1681442c2410c76b98a81166b1))
* return to source window on close ([#192](https://github.com/stevearc/aerial.nvim/issues/192)) ([a95b63f](https://github.com/stevearc/aerial.nvim/commit/a95b63f7dd5676dfbd0989d82ce3f2ee12343696))
* revert [#87](https://github.com/stevearc/aerial.nvim/issues/87) set buffer name ([#89](https://github.com/stevearc/aerial.nvim/issues/89)) ([7c65ec6](https://github.com/stevearc/aerial.nvim/commit/7c65ec6254ae6939837930b8bf31fa351c77b069))
* sanitize bad LSP symbol ranges ([#101](https://github.com/stevearc/aerial.nvim/issues/101)) ([b4a542e](https://github.com/stevearc/aerial.nvim/commit/b4a542e599143237dc82479089c1fd9b7ba4dcba))
* set aerial filetype after options so users can easily override ([#32](https://github.com/stevearc/aerial.nvim/issues/32)) ([e35c609](https://github.com/stevearc/aerial.nvim/commit/e35c609cffbea0b6e3b72caedaa41d9e5604b318))
* set buffer name after it's created ([64db090](https://github.com/stevearc/aerial.nvim/commit/64db090e13ed86a150a32ac6809d070ad0805c8a))
* set cursor in aerial window on first open ([ee8d7c8](https://github.com/stevearc/aerial.nvim/commit/ee8d7c8ece287482bf293fe568aa9dcfae62ef8a))
* set nolist in aerial window ([#150](https://github.com/stevearc/aerial.nvim/issues/150)) ([0de1bb9](https://github.com/stevearc/aerial.nvim/commit/0de1bb92f6de4a0915e5487ce9e53fb5704028c7))
* silence invalid buffer errors ([#242](https://github.com/stevearc/aerial.nvim/issues/242)) ([98a5092](https://github.com/stevearc/aerial.nvim/commit/98a50929cf51c806b424b7b0da1de90b5f5dd075))
* stack overflow in files with no symbols ([#36](https://github.com/stevearc/aerial.nvim/issues/36)) ([0f26a8d](https://github.com/stevearc/aerial.nvim/commit/0f26a8d2c63c7050aea9b19982b5402595126bd7))
* stop using vim.wo to set window options ([87f9133](https://github.com/stevearc/aerial.nvim/commit/87f91339901cc64f0a35a26463030a1988ed10dc))
* stuck loading on files with no supported backends ([96346e1](https://github.com/stevearc/aerial.nvim/commit/96346e106dd7d5c1fd76f4b451fc8defc55ddc12))
* stylua lint ([85c9bbb](https://github.com/stevearc/aerial.nvim/commit/85c9bbb69f0cdf7949ace27030e4d130cb9ffca3))
* support compound filetypes (fix [#33](https://github.com/stevearc/aerial.nvim/issues/33)) ([0385a6a](https://github.com/stevearc/aerial.nvim/commit/0385a6a148beb6f92cac91f76191cab9366b00a0))
* symbol count logic for buffer ([1bdaaac](https://github.com/stevearc/aerial.nvim/commit/1bdaaac714cf8dfe44929e19c75b77bc5ff14380))
* symbol sort order when ranges are equal ([#132](https://github.com/stevearc/aerial.nvim/issues/132)) ([f40bb38](https://github.com/stevearc/aerial.nvim/commit/f40bb382b1b2fc6a83fd452cc67bf6ecfba094e3))
* telescope picker shows symbols in order ([#169](https://github.com/stevearc/aerial.nvim/issues/169)) ([848779f](https://github.com/stevearc/aerial.nvim/commit/848779f03d038be951d0b8f73313e4d3388dabe4))
* tree collapsing works again (broken in 3a482fe) ([#112](https://github.com/stevearc/aerial.nvim/issues/112)) ([ece90c4](https://github.com/stevearc/aerial.nvim/commit/ece90c4820e7cea7be0aade9d19ef11f53bbc028))
* tree folding bug when symbols have the same name ([d2a1296](https://github.com/stevearc/aerial.nvim/commit/d2a12969b2a7f831b796469f75831f0cb242c086))
* **treesitter:** disable parsing of symbols from subtrees ([955ca39](https://github.com/stevearc/aerial.nvim/commit/955ca390bbe71d22aaef6901f50b603cdb2b8376))
* update deprecated nerd font icons ([8a59ed2](https://github.com/stevearc/aerial.nvim/commit/8a59ed2dc9563833ee0277b5bfd2e06faf95c2ab))
* update julia queries for new TS parser ([97279a1](https://github.com/stevearc/aerial.nvim/commit/97279a10cc797af96d3e7295026e51e4968d09a1))
* update LSP symbols when client attaches ([#68](https://github.com/stevearc/aerial.nvim/issues/68)) ([3bac149](https://github.com/stevearc/aerial.nvim/commit/3bac1490fece862e170344847de1830519bcd221))
* update markdown ts query for breaking parser change ([85baf29](https://github.com/stevearc/aerial.nvim/commit/85baf29b09bc19b2723a703df9e58a2563648c35))
* update tests for icon change ([f872cfe](https://github.com/stevearc/aerial.nvim/commit/f872cfe47311ad1ad9ba02c90f13df0bed30ee15))
* update tests for new norg parser ([490b574](https://github.com/stevearc/aerial.nvim/commit/490b574a66a0f7058b0ad10004a62054e0558075))
* use relative url for submodule definition ([#264](https://github.com/stevearc/aerial.nvim/issues/264)) ([c50874a](https://github.com/stevearc/aerial.nvim/commit/c50874a2943699397fc6c19102e7c67e2f832041))
* use selection_range for navigation ([#132](https://github.com/stevearc/aerial.nvim/issues/132)) ([0a8c2c5](https://github.com/stevearc/aerial.nvim/commit/0a8c2c57bae3a8ba1209b5f54e7c2de75e862fc2))
* use server_capabilities instead of resolved_capabilities ([d0066dd](https://github.com/stevearc/aerial.nvim/commit/d0066dd4a313c4b3651e4f2fd602addfb0ba4559))
* warn user if icons option will be ignored ([869b297](https://github.com/stevearc/aerial.nvim/commit/869b297922a311c0ab48386c909e551f1fb415e7))


### Performance Improvements

* improve performance for large files ([d527849](https://github.com/stevearc/aerial.nvim/commit/d52784941f2372baeaa53bb59e2d99b1b904113a))
* shave time off render by caching vim.fn ([#37](https://github.com/stevearc/aerial.nvim/issues/37)) ([d8de41d](https://github.com/stevearc/aerial.nvim/commit/d8de41d3e127d147b4bd5c136f7556454bbf8a94))
* slight optimization for telescope picker ([aff1bb8](https://github.com/stevearc/aerial.nvim/commit/aff1bb8fecff83d3e3a2d544c4d4e6d65718bd19))
* small perf win for big files ([#37](https://github.com/stevearc/aerial.nvim/issues/37)) ([f4aeaf2](https://github.com/stevearc/aerial.nvim/commit/f4aeaf2e93993bf33ce8f8c959ca39af84b5bb81))
* speed up foldexpr by removing vimscript ([#37](https://github.com/stevearc/aerial.nvim/issues/37)) ([7f084b0](https://github.com/stevearc/aerial.nvim/commit/7f084b0b2b6a9aad52dad12a0cac3181657c4f07))
* speed up foldexpr with caching ([#37](https://github.com/stevearc/aerial.nvim/issues/37)) ([7d0531b](https://github.com/stevearc/aerial.nvim/commit/7d0531bd2f240f471621a117b74c71ea1133da3d))


### cleanup

* Remove ability to use g:aerial variables to configure ([a1c0fa1](https://github.com/stevearc/aerial.nvim/commit/a1c0fa13754594a950d805fd3e416f279255d40e))


### Code Refactoring

* Link aerial to a source window, not a buffer ([#128](https://github.com/stevearc/aerial.nvim/issues/128)) ([d1e0bcd](https://github.com/stevearc/aerial.nvim/commit/d1e0bcd3458204ffaa8fdf311e97abbcc8ce84b7))
* remove deprecated functions ([15f9f05](https://github.com/stevearc/aerial.nvim/commit/15f9f054fff28735499967b0d6ac7838670b4c0c))
* split close_behavior into two new config options ([8e1d575](https://github.com/stevearc/aerial.nvim/commit/8e1d57562da73dc706165e02ec3228749d73c5f5))


### doc

* drop support for nvim &lt;0.8 ([e633b81](https://github.com/stevearc/aerial.nvim/commit/e633b816507e3948a8fd9702069a641b38e919cc))

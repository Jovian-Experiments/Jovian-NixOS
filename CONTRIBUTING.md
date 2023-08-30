Contributing to Jovian NixOS
============================

Development happens on the [GitHub Repository](https://github.com/Jovian-Experiments/Jovian-NixOS/).


Reporting issues
----------------

Yes, issues are contributions.

First, look around [in the opened and closed issues](https://github.com/Jovian-Experiments/Jovian-NixOS/issues?q=is%3Aissue+), someone might have reported the same issue.
In case of doubt or if it's not the same exact issue, feel free to [open a new issue](https://github.com/Jovian-Experiments/Jovian-NixOS/issues/new).

If you're not sure an issue is the same or not, especially an older closed issue, prefer opening a new issue, and in the issue tell us you suspect it could be related to that other issue.

First, identify if the issue not an upstream NixOS issue.
If it is not related to a device-specific issue (e.g. Steam Deck), to the Steam Deck UI integration, or to the few other system integration this repository handles, it is possibly a NixOS issue.
If you're unsure, it's okay to report it in the Jovian NixOS repository, at worst we'll explain how it's unrelated and ask you to report back to upstream and cross-reference.


Submitting changes
------------------

Opening [a Pull Request on the GitHub repository](https://github.com/NixOS/nixpkgs/pulls) is the preferred contribution workflow.

Though, if you can't, or don't want to, a properly `git format-patch` or `git send-email` contribution is fine too.
Find one or a few major contributor's e-mail address in the git repo, and send it there.

There are no strict guidelines.

 - Changes that are not about hardware-specific quirks, the Steam Deck UI, or system integration thereof should preferably be sent to Nixpkgs.
 - Implement as if you were contributing to Nixpkgs.
 - Test your changes, and tell us what you did do, and what you did not do.


“AI”-assisted changes
---------------------

> [!NOTE]
> Using pre-existing **boilerplate**, **snippets**, or **syntax suggestions** from your IDE are not considered as “AI”-assisted changes.

Contributions written largely with help of LLMs (*Large Language Models*), other “AI” (or non-“AI”), or similar systems are not welcome.
Such systems of concern are generally using statistical models built on “knowledge” acquired for the purpose without express consent, and with disregard of the authorship and attribution.

This includes, but is not limited to:

 - Using them to generate comments
 - Using them to generate documentation
 - Using them to generate code

Contributions should be largely authored by the people in the commit information, e.g. the `Committer,` `Author`, `Signed-off-by`, and `Co-authored-by` fields, exclusively.

If you are unsure, or you had help from automated “AI”-generation in *part* of your contribution, please tell us when contributing.
It does not mean the contribution will be rejected outright.
We will evaluate on a case-by-case basis.
We value honesty, and take it into consideration.


Other resources
---------------

 - [The NixOS/Nixpkgs `CONTRIBUTING.md`](https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md?)
 - [The Nixpkgs manual](https://nixos.org/manual/nixpkgs/unstable/)
 - [The NixOS manual](https://nixos.org/manual/nixos/unstable/)

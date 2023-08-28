[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](https://makeapullrequest.com)

1. [How to Contribute](#how-to-contribute)
    1. [Discussion](#discussion)
    1. [Issues](#issues)
    1. [Pull Requests](#pull-requests)

# How To Contribute

Every idea, suggestion, issue, pull request or question are welcomed and would
be appreciate!

As our time is precious, it should never be wasted.

In order to not waste yours, and to keep you feeling motivated by contributing,
please apply the following guidelines.

A request not well formulated would be rejected.  
But a reject does not
automatically mean the
end of the proposal.   
It may also be the beginnig of a new way to take.

However, every contributing will be processed and answered.

## Discussion

<details open><summary><b>Guidelines</b></summary>

Do not be afraid to start a new [discussion](https://github.com/AudeizReading/virtual-campus-42nice/discussions), if you have any questions. This section is made for this. There is no silly question.

Also, if you need the installation of a precise tool, the improvment of a
feature, whatever, the location is entirely
dedicated for this purpose.

Feel free to interact. Just be kind and polite to each others. Be patient, if
answers are not coming quickly.

Do not hesitate to transmit proposal and solutions to an already opened
discussion. Feel free to answer to each others. More fools, more fun.

I would take the liberty of muting/banishing anyone who will not be respectful to his neighbor.

We may not be
agree with everybody, but at least we can respect each others. Do not forget that
there is a human behind the screen. Sometimes, it is just a matter of misunderstanding.

</details>

## Issues

<details open><summary><b>Guidelines</b></summary>

If you find a security vulnerability, do NOT open an issue. Email
[alellouc[at]42nice[dot]student[dot]fr](mailto://alellouc@student.42nice.fr) instead.

If you noticed any bug, unexpected behaviour, please open an issue.

I will do my best for repairing what has failed. Please provide the following
context, for a better understanding of your troubles:

- Your host OS;
- The feature(s) from which you have encountered failure;
- A description on how it happens, screenshots are welcomed, code snippets also,
  what did you do, what did you expect to see and what did you see instead.
- Eventually, the resources that has helped you understand what has happened

Do not hesitate to use the comments section into the issue thread. Even the issue is
closed, a comment explaining why this should not be closed may change the
future of this closed one. Sometimes, it is just a matter of misunderstanding.

Every submitting would be studied and answered even if not accepted.

</details>

## Pull Requests

<details open><summary><b>Guidelines</b></summary>

- Fork the repository on your own account (the procedure is easily foundable).
- Be sure to have the latest version of the `main` branch.
- Create your own branch from the `main` branch.
- Work on your own on the feature you would to see improved.
    - **Makefile**
        - The **Makefile**'s rules have to be on a same subshell, on the same context line, if you prefer:  
            **Don't**:  
            ```Makefile
            target: prerequisites
                @instruction1
                @instruction2
            ```
            **Do**:  
            ```Makefile
            target: prerequisites
                @(instruction1 || true) \
                    && instruction2; \
                    instructions3 \
                    || instructions4
            ```
        - The commands have to be silented.  
            **Don't**:  
            ```Makefile
            target: prerequisites
                instruction1
            ```
            **Do**:  
            ```Makefile
            target: prerequisites
                @instruction1
            ```
        - If one rule executes a bash script, run it with the absolute path of
          the bash executable in interactive mode:  
            **Don't**:  
            ```Makefile
            target: prerequisites
                ./script-bash-that-install-features with parameters
            ```
            **Do**:  
            ```Makefile
            target: prerequisites
                /bin/bash -c "./script-bash-that-install-features with parameters"
            ```
        - Let the rule be `.PHONY`, if the target is not a filename.
    - **Dockerfile**
        - You should never submit a Dockerfile. It would instantly be rejected.  
        Instead, submit your need or idea on the issue page or discussion [OPEN AN ISSUE](https://github.com/AudeizReading/virtual-campus-42nice/issues) or [START A DISCUSSION](https://github.com/AudeizReading/virtual-campus-42nice/discussions).
    - **Script Syntax**
        - If you feel confident for integrating features into the main script,
          or wrting a scripting that be included in the main script, the shell syntax to be used is the `bash` syntax. Albeit, it is not portable, it offers broader options to manipulate string datas more easily.  
          Do only if you know what you are doing or be prepared to be rejected.
          It is rather to submit any idea or need to the dedicated pages: [OPEN AN ISSUE](https://github.com/AudeizReading/virtual-campus-42nice/issues) or [START A DISCUSSION](https://github.com/AudeizReading/virtual-campus-42nice/discussions).
    - **README**  
        The syntax used for README is markdown for GitHub (you can mix some HTML
        tags within). Try to follow the accessibility guidelines as much as possible:
        [Microsoft accessibility guidelines](https://learn.microsoft.com/fr-fr/style-guide/accessibility/accessibility-guidelines-requirements).
- Commit your enhancements on your new branch with the more explicit and
  detailed commit message.
- Push on your remote origin, then push on the upstram remote (here) on the same
  branch that you have just created. Every push on the inappropriate branch
  would be rejected. No work on the `main` branch are allowed.
- Go on the GitHub repository's pull request page, create a new pull request
  from your remote branch, to your upstream new name branch. A Pull Request made
  on the inappropriate branch would be closed and rejected.
- As I am the only one to review PR for the moment, I will process it as soon as
  possible, the most quickly possible, as it may be your work tool.

Do not hesitate to use the comments section into the PR thread. Even the PR is
closed, a comment explaining why the PR should not be closed may change the
future of this closed one. Sometimes, it is just a matter of misunderstanding.

Every submitting would be studied and answered even if not accepted.

Be assured that your request will not remain in vain.

This guide is subject to change on a regular basis.

</details>

[CONTRIBUTING](.github/CONTRIBUTING.md)

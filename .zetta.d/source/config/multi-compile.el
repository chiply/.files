(use-package multi-compile)

;; notes on multi compile

;; 1. The value here can be really quickly achieved by simply filling out multi compile a list with a few of the very well-known commands that I have for my projects.
;; 2. Before filling things in in this way, it is likely advantageous to test the different types of triggers that I want to use. For example project specific triggers will be something really useful to test.
;; 3. Although we are developing the more complex command building tool inspired by foreman, we can still achieve almost all of the value by investing a small amount of time into filling out multi complier pile manually. Watch more it's probably necessary to do this in order to get a better intuition around multi compile and its features and how this data structure is usedBefore moving onto any sort of extension or extensibility. I doubt this but for example it could be completely unnecessary to have a separate interface for command building. Either the templates could be powerful enough, or some thing in multi compile could provide this feature for me with a little bit of elbow grease.
;; 4. Important observation about the data structure is that the A-list is simply a list of doc pairs. The left hand side of the pair is the trigger in the right hand side of the pair is a list of available commands that will be exposed in the menu.  If multiple triggers are fired in a particular situation than the right hand signs associated with these triggers are union so all of the available commands in the right hand sides are available in the selection menu. This set up has huge implications for extensibility. For example a particular trigger, let's say just associated with tests, could expose a specific set of testing commands.This would be added to a list of let's say more common commands like building a dock or file or running to get command or running a server or running some logs.  Essentially any project can simply add its Relevant commands to this list to the multi compile a list in order to make those commands available in a menu. Of course the appropriate trigger Hass to be set, but that shouldn't be difficult to maintain.
;; 5. The multi compile run command should be really easy to override with something custom in order to use different programs. The default should probably be compile it seems to be good at handling most things and it's a pretty good fallback, but we want to be able to allow for things like starting every term session stuff like that I wonder if the nature of the executor would affect the command. For example with the term we might need to open retirement and CD into a directory. Where is with compileThe direct to remain I'll get specified or make it auto in for. We'll cross that bridge when we get there, it's just probably likely that we will need some kind of layer that standardize is the interface to all the different types of executors in order of abstract away any complex details like how for example directories get specified between different executors.


;; NEED TO FIX THE COMPILE RENAMING THING!!!


;; settings around the alist:
;; executor to use, display settings, many things from 4mn


;; step 1 fill in some useful commands
;; step 2 test changing the default directory
(setq
 multi-compile-alist
 '((python-mode . (
                   ("pytest project" . "echo pytest project")
                   ("sleepy" . "sleep 3")
                   ))
   (python-mode . (
                   ("hello universe example" . "echo hello uni")
                   ("sleepier" . "sleep 3")
                   ))
   ))

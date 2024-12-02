# pr_h23_irlandes_web

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

Instrucciones Deploy

Comandos terminal:
1. flutter build web
2. En el index de index.html:
<script type="module">
  // Import the functions you need from the SDKs you need
  import { initializeApp } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js";
  // TODO: Add SDKs for Firebase products that you want to use
  // https://firebase.google.com/docs/web/setup#available-libraries

  // Your web app's Firebase configuration
  const firebaseConfig = {
    apiKey: "AIzaSyAiqUetCVljCjXYGheedrU791TDO-cofps",
    authDomain: "db-col-irlandes.firebaseapp.com",
    projectId: "db-col-irlandes",
    storageBucket: "db-col-irlandes.appspot.com",
    messagingSenderId: "345770585745",
    appId: "1:345770585745:web:f6840fb42da9ac69c39930"
  };

  // Initialize Firebase
  const app = initializeApp(firebaseConfig);
</script>

3. Firebase login: error
3.1 firebase login:add

firebase login:list
firebase login:use
Example:

firebase login:add david@example.com
firebase login:add alice@example.com
firebase login:add bob@example.com
firebase login:use alice@example.com
firebase login:list
firebase deploy --only hosting # deploy as alice@example.com

firebase login

4. firebase login --reauth
5. firebase login
6. firebase init hosting

chris@DESKTOP-R01OM7D MINGW64 /c/Proyectos/Flutter/Univalle2/ColIrlandes/PR-H23-IRLANDES-movil/pr_h23_irlandes_web (dev)
$ firebase init hosting

     ######## #### ########  ######## ########     ###     ######  ########
     ##        ##  ##     ## ##       ##     ##  ##   ##  ##       ##
     ######    ##  ########  ######   ########  #########  ######  ######
     ##        ##  ##    ##  ##       ##     ## ##     ##       ## ##
     ##       #### ##     ## ######## ########  ##     ##  ######  ########

You're about to initialize a Firebase project in this directory:

  C:\Proyectos\Flutter\Univalle2\ColIrlandes\PR-H23-IRLANDES-movil\pr_h23_irlandes_web

Before we get started, keep in mind:

  * You are currently outside your home directory

? Are you ready to proceed? Yes

=== Account Setup

Which account do you want to use for this project? Choose an account or add a new one now

? Please select an option: cmontanosa@univalle.edu

+  Using account: cmontanosa@univalle.edu

=== Project Setup

First, let's associate this project directory with a Firebase project.
You can create multiple project aliases by running firebase use --add,
but for now we'll just set up a default project.

? Please select an option: Use an existing project
? Select a default Firebase project for this directory: db-col-irlandes (db-col-irlandes)
i  Using project db-col-irlandes (db-col-irlandes)

=== Hosting Setup

Your public directory is the folder (relative to your project directory) that
will contain Hosting assets to be uploaded with firebase deploy. If you
have a build process for your assets, use your build's output directory.

? What do you want to use as your public directory? public
? Configure as a single-page app (rewrite all urls to /index.html)? Yes
? Set up automatic builds and deploys with GitHub? No
+  Wrote public/index.html

i  Writing configuration info to firebase.json...
i  Writing project information to .firebaserc...

+  Firebase initialization complete!

7. firebase.json:     "public": "build/web",
8. firebase deploy



//Deploy a web
1. flutter build web


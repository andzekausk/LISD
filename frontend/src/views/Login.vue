<template>
    <div>
        <h1>Login lapa</h1>
        <div>
            
            <input v-model="username" placeholder="Username" />
            <input v-model="password" type="password" placeholder="Password" />
            <button @click="usernameLogin">Login</button>
            <button @click="signInWithGoogle" v-if="!authStore.token">Sign in with Google</button>
        </div>
    </div>
  </template>
  
  <script setup>
    import { useAuthStore } from "./../stores/auth";
    import { ref } from "vue";
    import { useRouter } from "vue-router";
    
    const authStore = useAuthStore(); 
    const router = useRouter();
    const username = ref('');
    const password = ref('');
  
    const usernameLogin = async () => {
      try {
        await authStore.loginWithUsername(username.value, password.value);
        router.push('/');
    } catch (error) {
        console.error("Login error:", error);
      }
    };

    const signInWithGoogle = async () => {
    try {
      await authStore.loginWithGoogle();
      router.push('/');
    } catch (error) {
      console.error("Login error:", error);
    }
  };
  </script>
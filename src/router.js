import Vue from "vue";
import Router from "vue-router";

Vue.use(Router);

const routes = [
    {
      path: "/",
      name: "Visualization",
      component: () => import("@/views/Visualization.vue"),
    },
    {
      path: "/404",
      name: "error404",
      component: () => import("@/components/Error404.vue"),
    },
    {
      path: "*",
      redirect: { name: "error404" },
    },
 ];

const router = new Router({
  mode: "history",
  base: import.meta.env.BASE_URL,
  routes,

});

export default router;

import "regenerator-runtime/runtime";
import Vue from "vue";
import router from "./router";
import { store } from "./store/store";
import App from "./App.vue";
import browserDetect from "vue-browser-detect-plugin";
import uswds from "@uswds/uswds"
import Vuetify from "vuetify";
import { library } from "@fortawesome/fontawesome-svg-core";
import { FontAwesomeIcon } from "@fortawesome/vue-fontawesome";
import "vuetify/dist/vuetify.min.css";
import VueImg from 'v-img';


// social icons
import { faTwitterSquare } from "@fortawesome/free-brands-svg-icons";
import { faFacebookSquare } from "@fortawesome/free-brands-svg-icons";
import { faGithub } from "@fortawesome/free-brands-svg-icons";
import { faFlickr } from "@fortawesome/free-brands-svg-icons";
import { faYoutubeSquare } from "@fortawesome/free-brands-svg-icons";
import { faInstagram } from "@fortawesome/free-brands-svg-icons";

const vueImgConfig = {
  altAsTitle: true
}

Vue.component("FontAwesomeIcon", FontAwesomeIcon);

// social icons
library.add(faTwitterSquare, faFacebookSquare, faGithub, faFlickr, faYoutubeSquare, faInstagram);

Vue.config.productionTip = false;
Vue.use(browserDetect);
Vue.use(uswds);
Vue.use(Vuetify);
Vue.use(VueImg, vueImgConfig);


const app = new Vue({
  router,
  store,
  render: (h) => h(App),
}).$mount("#app");

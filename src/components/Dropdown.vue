<template>
  <div
    class="dropdown"
    :class="{ 'is-active': isOpen }"
  >
    <div
      class="dropdown-trigger"
      @click="toggleDropdown"
    >
      <button
        class="button"
        aria-haspopup="true"
        aria-controls="dropdown-menu"
      >
        <span>{{ selected }}</span>
        <span class="icon is-small">
          <i
            class="fas fa-angle-down"
            aria-hidden="true"
          />
        </span>
      </button>
    </div>
    <div
      id="dropdown-menu"
      class="dropdown-menu"
      role="menu"
    >
      <div class="dropdown-content">
        <a
          v-for="option in options"
          :key="option"
          href="#"
          class="dropdown-item"
          @click="selectOption(option)"
        >
          {{ option }}
        </a>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'DropdownMenu',
  props: {
    options: {
      type: Array,
      required: true
    },
    value: {
      type: String,
      default: ''
    }
  },
  data() {
    return {
      isOpen: false,
      selected: this.value
    }
  },
  methods: {
    toggleDropdown() {
      this.isOpen = !this.isOpen
    },
    selectOption(option) {
      this.isOpen = false
      this.selected = option
      this.$emit('input', option)
    }
  }
}
</script>

<style scoped>
.dropdown {
  position: relative;
  width: 50vw;
}
.dropdown-content {
  position: absolute;
  background-color: white;
  width: 100%;
  border: 1px solid #dbdbdb;
  border-radius: 3px;
  box-shadow: 2px 2px 3px rgba(0,0,0,.1);
  z-index: 1;
}
</style>

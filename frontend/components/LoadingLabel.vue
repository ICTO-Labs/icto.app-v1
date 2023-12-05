<template>
  <span :class="{
        'vue-loading-button': true,
        'default-styles': styled,
        'loading': loading,
      }" :disabled="loading" type="button">
      <slot>Submit</slot>
      <span class="spinner">
        <span></span>
        <span></span>
        <span></span>
        <span></span>
      </span>
    </span>
  </template>
  
  <script>
  export default {
    name: "LoadingLabel",
    props: {
      loading: {
        type: Boolean,
        required: false,
        default: false
      },
      styled: {
        type: Boolean,
        required: false,
        default: false
      }
    }
  };
  </script>
  
  <style scoped>
  
  span::-moz-focus-inner {
    border-style: none;
    padding: 0;
  }
  span:-moz-focusring {
    outline: 1px dotted ButtonText;
  }
  .loading{
    cursor: not-allowed;
    color: #ccc;
  }
  /* loading styles */
  span {
    position: relative;
    -webkit-transition: all 0.2s;
    transition: all 0.2s;
    transition-timing-function: ease-in;
  }
  .spinner {
    line-height: 1.15;
    position: absolute;
    top: 50%;
    left: auto;
    right: 1.7rem;
    margin: -0.5em;
    opacity: 0;
    transition-property: padding, opacity;
    transition-duration: 0.2s, 0.2s;
    transition-timing-function: ease-in, ease;
    transition-delay: 0s, 0.2s;
  }
  .spinner span {
    box-sizing: border-box;
    display: inline-block;
    position: absolute;
    right: 0;
    width: 1rem;
    height: 1rem;
    opacity: 1;
    border: 2.4px solid #fff;
    border-radius: 50%;
    animation: spinner-4e61db10 1.2s cubic-bezier(0.5, 0, 0.5, 1) infinite;
    border-color: #afabab transparent transparent transparent;
  }
  .spinner span:nth-child(1) {
    animation-delay: 0.45s;
  }
  .spinner span:nth-child(2) {
    animation-delay: 0.3s;
  }
  .spinner span:nth-child(3) {
    animation-delay: 0.15s;
  }
  .loading {
    padding-right: 3rem !important;
  }
  .loading .spinner {
    opacity: 1;
  }
  .loading .spinner span {
    opacity: 1;
  }
  a:not(:disabled) {
    transition-delay: 0.2s;
  }
  a:not(:disabled) .spinner span {
    box-shadow: 0 0 0 0.2rem #888 inset;
    border: 7.4px solid transparent;
    -webkit-transition: all 0.4s;
    transition: all 0.4s;
  }
  a:not(:disabled) .spinner span:nth-child(1) {
    transform: rotate(0deg) !important;
  }
  a:not(:disabled) .spinner span:nth-child(2) {
    transform: rotate(90deg) !important;
  }
  a:not(:disabled) .spinner span:nth-child(3) {
    transform: rotate(180deg) !important;
  }
  a:not(:disabled) .spinner span:nth-child(4) {
    transform: rotate(270deg) !important;
  }
  @keyframes spinner {
    0% {
      transform: rotate(0deg);
    }
    100% {
      transform: rotate(360deg);
    }
  }
  
  /* optional styles */
  .default-styles {
    color: white;
    background-color: blue;
    border: solid 1px transparent;
    border-radius: 4px;
    cursor: pointer;
    padding: 8px 16.5px 8px 16px;
    line-height: 1.9rem;
  }
  .default-styles:disabled {
    color: #cccccc;
    pointer-events: stroke;
    cursor: not-allowed;
  }
  .default-styles:focus {
    outline: none;
    box-shadow: 0 0 0 3px lightblue, 0 0 0 1.5px lightblue;
  }
  .default-styles .spinner span {
    top: 0rem;
    width: 1.2rem;
    height: 1.2rem;
    border: 3.4px solid #fff;
    border-color: #fff transparent transparent transparent;
  }
  .default-styles:not(:disabled) .spinner span {
    border: 8.4px solid transparent;
    box-shadow: 0 0 0 0.1rem #fff inset;
  }
  </style>
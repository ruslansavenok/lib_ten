import 'phoenix_html'
import { renderReactComponent } from './react-components'

window.LibTen.renderReactComponent = renderReactComponent

function toggleHeight(el, isVisible = true) {
  if (el.clientHeight === 0 && isVisible) {
    el.style.maxHeight = 'auto'
    el.style.maxHeight = `${el.scrollHeight}px`
  } else {
    el.style.maxHeight = '0px'
  }
}

document.addEventListener('DOMContentLoaded', () => {
  const navbarMenuToggler = document.getElementById('js-navbar-menu-toggle-btn')
  const navbarMenu = document.getElementById('js-navbar-menu')
  const navbarMenuSubgroupSelector = '.navbar-menu__subgroup'

  if (!navbarMenu) return

  function toggleNavbarSubgroup(menuItem, isVisible = true) {
    menuItem.classList.toggle('navbar-menu__item--active', isVisible)
    toggleHeight(menuItem.querySelector(navbarMenuSubgroupSelector), isVisible)
  }

  navbarMenuToggler.addEventListener('click', () => {
    navbarMenuToggler.classList.toggle('navbar-burger-btn--active')
    navbarMenu.classList.toggle('navbar-menu--visible')
  })

  Array.from(document.querySelectorAll(navbarMenuSubgroupSelector))
    .map(node => node.parentNode)
    .forEach(node => {
      let isHovered = false

      node.addEventListener('click', () => {
        if (isHovered || navbarMenuToggler.style.display === 'none') return
        toggleNavbarSubgroup(node)
      })

      node.addEventListener('mouseenter', () => {
        isHovered = true
        toggleNavbarSubgroup(node)
      })
      node.addEventListener('mouseleave', () => {
        isHovered = false
        toggleNavbarSubgroup(node, false)
      })
    })
})

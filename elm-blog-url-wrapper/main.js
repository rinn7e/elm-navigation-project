import './src/style.css'
import { Elm } from './src/Main.elm'

// The signed-in user is kept in localStorage, so a refresh keeps it
const USER_KEY = 'elm-blog-user'

const app = Elm.Main.init({
  flags: localStorage.getItem(USER_KEY),
})

app.ports.storeUser.subscribe((user) => {
  if (user === null) {
    localStorage.removeItem(USER_KEY)
  } else {
    localStorage.setItem(USER_KEY, user)
  }
})

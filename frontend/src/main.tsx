import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import App from './App'
import { applyLanguageMetadata } from './content'
import './styles.css'

applyLanguageMetadata()

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)

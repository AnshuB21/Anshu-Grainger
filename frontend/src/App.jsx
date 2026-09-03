import { useEffect, useState } from 'react'
import './App.css'

function App() {
  const [products, setProducts] = useState([])
  const [name, setName] = useState('')
  const [error, setError] = useState('')
  const [saving, setSaving] = useState(false)

  async function loadProducts() {
    try {
      const response = await fetch('/api/products')
      if (!response.ok) throw new Error('Could not load products')
      setProducts(await response.json())
      setError('')
    } catch {
      setError('Backend is not reachable. Start the app with start-app.ps1.')
    }
  }

  useEffect(() => {
    // oxlint-disable-next-line react/set-state-in-effect
    loadProducts()
  }, [])

  async function addProduct(event) {
    event.preventDefault()
    const trimmedName = name.trim()
    if (!trimmedName) return

    setSaving(true)
    try {
      const response = await fetch('/api/products', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name: trimmedName }),
      })
      if (!response.ok) throw new Error('Could not create product')
      setName('')
      setError('')
      await loadProducts()
    } catch {
      setError('Could not create the product. Check that the backend is running.')
    } finally {
      setSaving(false)
    }
  }

  return (
    <main>
      <section className="card">
        <header>
          <p className="eyebrow">Take-home exercise</p>
          <h1>Products</h1>
          <p>Add a product and it will appear in the list.</p>
        </header>

        <form onSubmit={addProduct}>
          <label htmlFor="product-name">Product name</label>
          <div className="form-row">
            <input
              id="product-name"
              value={name}
              onChange={(event) => setName(event.target.value)}
              maxLength={200}
              placeholder="Example: P1"
              autoFocus
            />
            <button disabled={saving || !name.trim()}>
              {saving ? 'Adding...' : 'Add product'}
            </button>
          </div>
        </form>

        {error && <p className="error" role="alert">{error}</p>}

        <section className="list-section">
          <h2>Product list</h2>
          {products.length === 0 && !error ? (
            <p className="empty">No products yet.</p>
          ) : (
            <ul>
              {products.map((product) => (
                <li key={product.id}>
                  <span>{product.name}</span>
                  <small>#{product.id}</small>
                </li>
              ))}
            </ul>
          )}
        </section>
      </section>
    </main>
  )
}

export default App

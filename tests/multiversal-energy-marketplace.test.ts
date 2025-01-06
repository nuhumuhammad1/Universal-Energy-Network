import { describe, it, expect, beforeEach } from 'vitest';

// Simulated contract state
let listingCount = 0;
const energyListings = new Map();
const tokenBalances = new Map();

// Simulated contract functions
function createListing(universeOrigin: string, energyType: string, amount: number, price: number, expiration: number, seller: string) {
  const listingId = ++listingCount;
  energyListings.set(listingId, {
    seller,
    universeOrigin,
    energyType,
    amount,
    price,
    expiration: Date.now() + expiration * 1000 // Convert to milliseconds
  });
  return listingId;
}

function purchaseEnergy(listingId: number, buyer: string) {
  const listing = energyListings.get(listingId);
  if (!listing) throw new Error('Invalid listing');
  if (Date.now() > listing.expiration) throw new Error('Listing expired');
  const buyerBalance = tokenBalances.get(buyer) || 0;
  if (buyerBalance < listing.price) throw new Error('Insufficient balance');
  
  // Transfer tokens
  tokenBalances.set(buyer, buyerBalance - listing.price);
  const sellerBalance = tokenBalances.get(listing.seller) || 0;
  tokenBalances.set(listing.seller, sellerBalance + listing.price);
  
  // Remove listing
  energyListings.delete(listingId);
  return true;
}

function cancelListing(listingId: number, canceler: string) {
  const listing = energyListings.get(listingId);
  if (!listing) throw new Error('Invalid listing');
  if (listing.seller !== canceler) throw new Error('Not authorized');
  energyListings.delete(listingId);
  return true;
}

// Helper function to set token balance
function setTokenBalance(account: string, balance: number) {
  tokenBalances.set(account, balance);
}

describe('Multiversal Energy Marketplace Contract', () => {
  beforeEach(() => {
    listingCount = 0;
    energyListings.clear();
    tokenBalances.clear();
  });
  
  it('should create a new energy listing', () => {
    const id = createListing('Universe-Alpha', 'Dark Energy', 1000000, 5000, 3600, 'seller1');
    expect(id).toBe(1);
    const listing = energyListings.get(id);
    expect(listing.universeOrigin).toBe('Universe-Alpha');
    expect(listing.energyType).toBe('Dark Energy');
    expect(listing.amount).toBe(1000000);
  });
  
  it('should allow purchasing of energy', () => {
    const listingId = createListing('Universe-Beta', 'Antimatter', 500000, 8000, 7200, 'seller2');
    setTokenBalance('buyer1', 10000);
    expect(purchaseEnergy(listingId, 'buyer1')).toBe(true);
    expect(tokenBalances.get('buyer1')).toBe(2000);
    expect(tokenBalances.get('seller2')).toBe(8000);
    expect(energyListings.has(listingId)).toBe(false);
  });
  
  it('should not allow purchase with insufficient balance', () => {
    const listingId = createListing('Universe-Gamma', 'Tachyon Particles', 200000, 3000, 5400, 'seller3');
    setTokenBalance('buyer2', 2000);
    expect(() => purchaseEnergy(listingId, 'buyer2')).toThrow('Insufficient balance');
  });
  
  it('should allow cancellation of listing by seller', () => {
    const listingId = createListing('Universe-Delta', 'Zero-Point Energy', 1500000, 12000, 10800, 'seller4');
    expect(cancelListing(listingId, 'seller4')).toBe(true);
    expect(energyListings.has(listingId)).toBe(false);
  });
  
  it('should not allow cancellation by non-seller', () => {
    const listingId = createListing('Universe-Epsilon', 'Hawking Radiation', 100000, 2000, 9000, 'seller5');
    expect(() => cancelListing(listingId, 'unauthorized_user')).toThrow('Not authorized');
  });
  
  it('should not allow purchase of expired listing', async () => {
    const listingId = createListing('Universe-Zeta', 'Cosmic Strings', 300000, 6000, 1, 'seller6');
    setTokenBalance('buyer3', 7000);
    
    // Wait for the listing to expire
    await new Promise(resolve => setTimeout(resolve, 1100));
    
    expect(() => purchaseEnergy(listingId, 'buyer3')).toThrow('Listing expired');
  });
});


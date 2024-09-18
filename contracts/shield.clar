;; Define the contract
(define-data-var owner principal tx-sender)

;; Define a map to store IP registrations
(define-map ip-registrations
  { ip-id: uint }
  { owner: principal, timestamp: uint, hash: (buff 32) }
)

;; Define a map to track registered hashes
(define-map registered-hashes
  { hash: (buff 32) }
  { ip-id: uint }
)

;; Define a counter for IP IDs
(define-data-var ip-counter uint u0)

;; Function to register new IP
(define-public (register-ip (ip-hash (buff 32)))
  (let
    (
      (new-id (+ (var-get ip-counter) u1))
    )
    ;; Perform input validation
    (asserts! (is-eq (len ip-hash) u32) (err u400)) ;; Ensure the hash is exactly 32 bytes
    (asserts! (not (is-eq ip-hash 0x0000000000000000000000000000000000000000000000000000000000000000)) (err u401)) ;; Ensure the hash is not all zeros
    (asserts! (is-none (map-get? registered-hashes { hash: ip-hash })) (err u402)) ;; Ensure the hash hasn't been registered before
    
    ;; Register the IP
    (map-set ip-registrations
      { ip-id: new-id }
      { owner: tx-sender, timestamp: block-height, hash: ip-hash }
    )
    ;; Track the registered hash
    (map-set registered-hashes
      { hash: ip-hash }
      { ip-id: new-id }
    )
    (var-set ip-counter new-id)
    (ok new-id)
  )
)

;; Function to check IP ownership
(define-read-only (check-ip-ownership (ip-id uint))
  (let
    (
      (ip-data (map-get? ip-registrations { ip-id: ip-id }))
    )
    (if (is-some ip-data)
      (ok (get owner (unwrap-panic ip-data)))
      (err u404)
    )
  )
)

;; Function to verify IP hash
(define-read-only (verify-ip-hash (ip-id uint) (hash-to-verify (buff 32)))
  (let
    (
      (ip-data (map-get? ip-registrations { ip-id: ip-id }))
    )
    (if (is-some ip-data)
      (ok (is-eq (get hash (unwrap-panic ip-data)) hash-to-verify))
      (err u404)
    )
  )
)

;; Function to transfer IP ownership
(define-public (transfer-ip (ip-id uint) (new-owner principal))
  (let
    (
      (current-ip-counter (var-get ip-counter))
    )
    ;; Perform input validation
    (asserts! (<= ip-id current-ip-counter) (err u405)) ;; Ensure the ip-id is not greater than the current counter
    (asserts! (> ip-id u0) (err u406)) ;; Ensure the ip-id is greater than 0
    
    (let
      (
        (ip-data (map-get? ip-registrations { ip-id: ip-id }))
      )
      (asserts! (is-some ip-data) (err u404)) ;; Ensure the IP exists
      (let
        (
          (unwrapped-ip-data (unwrap-panic ip-data))
        )
        (asserts! (is-eq tx-sender (get owner unwrapped-ip-data)) (err u403)) ;; Ensure the sender is the current owner
        (map-set ip-registrations
          { ip-id: ip-id }
          (merge unwrapped-ip-data { owner: new-owner })
        )
        (ok true)
      )
    )
  )
)

;; Function to check if a hash is already registered
(define-read-only (is-hash-registered (ip-hash (buff 32)))
  (is-some (map-get? registered-hashes { hash: ip-hash }))
)
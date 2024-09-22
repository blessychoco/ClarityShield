;; Smart Contract on Intellectual Property Protection with Expiration Date
;; Define error codes
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-INVALID-HASH-LENGTH (err u1001))
(define-constant ERR-HASH-ALL-ZEROS (err u1002))
(define-constant ERR-HASH-ALREADY-REGISTERED (err u1003))
(define-constant ERR-IP-NOT-FOUND (err u1004))
(define-constant ERR-INVALID-IP-ID (err u1005))
(define-constant ERR-IP-ID-OUT-OF-RANGE (err u1006))
(define-constant ERR-IP-EXPIRED (err u1007))

;; Define the contract
(define-data-var owner principal tx-sender)

;; Define a map to store IP registrations
(define-map ip-registrations
  { ip-id: uint }
  { owner: principal, timestamp: uint, hash: (buff 32), expiration: (optional uint) }
)

;; Define a map to track registered hashes
(define-map registered-hashes
  { hash: (buff 32) }
  { ip-id: uint }
)

;; Define a counter for IP IDs
(define-data-var ip-counter uint u0)

;; Function to register new IP
(define-public (register-ip (ip-hash (buff 32)) (expiration-block (optional uint)))
  (let
    (
      (new-id (+ (var-get ip-counter) u1))
    )
    ;; Perform input validation
    (asserts! (is-eq (len ip-hash) u32) ERR-INVALID-HASH-LENGTH)
    (asserts! (not (is-eq ip-hash 0x0000000000000000000000000000000000000000000000000000000000000000)) ERR-HASH-ALL-ZEROS)
    (asserts! (is-none (map-get? registered-hashes { hash: ip-hash })) ERR-HASH-ALREADY-REGISTERED)
    
    ;; Register the IP
    (map-set ip-registrations
      { ip-id: new-id }
      { owner: tx-sender, timestamp: block-height, hash: ip-hash, expiration: expiration-block }
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
      (let
        (
          (unwrapped-ip-data (unwrap-panic ip-data))
          (current-block block-height)
        )
        (if (and
              (is-some (get expiration unwrapped-ip-data))
              (>= current-block (unwrap-panic (get expiration unwrapped-ip-data)))
            )
          ERR-IP-EXPIRED
          (ok (get owner unwrapped-ip-data))
        )
      )
      ERR-IP-NOT-FOUND
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
      (let
        (
          (unwrapped-ip-data (unwrap-panic ip-data))
          (current-block block-height)
        )
        (if (and
              (is-some (get expiration unwrapped-ip-data))
              (>= current-block (unwrap-panic (get expiration unwrapped-ip-data)))
            )
          ERR-IP-EXPIRED
          (ok (is-eq (get hash unwrapped-ip-data) hash-to-verify))
        )
      )
      ERR-IP-NOT-FOUND
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
    (asserts! (<= ip-id current-ip-counter) ERR-IP-ID-OUT-OF-RANGE)
    (asserts! (> ip-id u0) ERR-INVALID-IP-ID)
    
    (let
      (
        (ip-data (map-get? ip-registrations { ip-id: ip-id }))
      )
      (asserts! (is-some ip-data) ERR-IP-NOT-FOUND)
      (let
        (
          (unwrapped-ip-data (unwrap-panic ip-data))
          (current-block block-height)
        )
        (asserts! (is-eq tx-sender (get owner unwrapped-ip-data)) ERR-NOT-AUTHORIZED)
        (asserts! (or
                    (is-none (get expiration unwrapped-ip-data))
                    (< current-block (unwrap-panic (get expiration unwrapped-ip-data)))
                  )
                  ERR-IP-EXPIRED
        )
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

;; Function to extend IP registration
(define-public (extend-ip-registration (ip-id uint) (new-expiration uint))
  (let
    (
      (ip-data (map-get? ip-registrations { ip-id: ip-id }))
    )
    (asserts! (is-some ip-data) ERR-IP-NOT-FOUND)
    (let
      (
        (unwrapped-ip-data (unwrap-panic ip-data))
      )
      (asserts! (is-eq tx-sender (get owner unwrapped-ip-data)) ERR-NOT-AUTHORIZED)
      (asserts! (> new-expiration block-height) ERR-INVALID-IP-ID)
      (map-set ip-registrations
        { ip-id: ip-id }
        (merge unwrapped-ip-data { expiration: (some new-expiration) })
      )
      (ok true)
    )
  )
)
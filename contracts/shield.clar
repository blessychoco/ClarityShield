;; Define the contract
(define-data-var owner principal tx-sender)

;; Define a map to store IP registrations
(define-map ip-registrations
  { ip-id: uint }
  { owner: principal, timestamp: uint, hash: (buff 32) }
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
    
    (map-set ip-registrations
      { ip-id: new-id }
      { owner: tx-sender, timestamp: block-height, hash: ip-hash }
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
      (ip-data (map-get? ip-registrations { ip-id: ip-id }))
    )
    (if (is-some ip-data)
      (if (is-eq tx-sender (get owner (unwrap-panic ip-data)))
        (begin
          (map-set ip-registrations
            { ip-id: ip-id }
            (merge (unwrap-panic ip-data) { owner: new-owner })
          )
          (ok true)
        )
        (err u403)
      )
      (err u404)
    )
  )
)
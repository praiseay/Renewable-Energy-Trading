;; Energy Credit Management Contract

(define-fungible-token energy-credit)

(define-data-var credit-price uint u100)  ;; Price in STX per 1 kWh

(define-data-var contract-owner principal tx-sender)

(define-public (mint-credits (amount uint))
    (let
        ((cost (* amount (var-get credit-price))))
        (try! (stx-transfer? cost tx-sender (as-contract tx-sender)))
        (ok (ft-mint? energy-credit amount tx-sender))
    )
)

(define-public (transfer-credits (amount uint) (recipient principal))
    (ft-transfer? energy-credit amount tx-sender recipient)
)

(define-public (burn-credits (amount uint))
    (ft-burn? energy-credit amount tx-sender)
)

(define-read-only (get-credit-balance (account principal))
    (ok (ft-get-balance energy-credit account))
)

(define-public (set-credit-price (new-price uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
        (ok (var-set credit-price new-price))
    )
)

(define-read-only (get-credit-price)
    (ok (var-get credit-price))
)

(define-public (transfer-ownership (new-owner principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
        (ok (var-set contract-owner new-owner))
    )
)

(define-read-only (get-contract-owner)
    (ok (var-get contract-owner))
)


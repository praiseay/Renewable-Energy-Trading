;; Automated Billing Contract

(define-map energy-consumption
    { user: principal, month: uint, year: uint }
    { consumed: uint, produced: uint }
)

(define-public (record-energy-data (user principal) (month uint) (year uint) (consumed uint) (produced uint))
    (begin
        (asserts! (is-eq tx-sender (contract-call? .energy-dao get-admin)) (err u403))
        (ok (map-set energy-consumption { user: user, month: month, year: year } { consumed: consumed, produced: produced }))
    )
)

(define-public (process-monthly-bill (user principal) (month uint) (year uint))
    (let
        ((energy-data (unwrap! (map-get? energy-consumption { user: user, month: month, year: year }) (err u404)))
         (net-consumption (- (get consumed energy-data) (get produced energy-data))))
        (if (> net-consumption u0)
            (contract-call? .energy-credit burn-credits net-consumption)
            (contract-call? .energy-credit mint-credits (abs net-consumption))
        )
    )
)

(define-read-only (get-energy-data (user principal) (month uint) (year uint))
    (map-get? energy-consumption { user: user, month: month, year: year })
)


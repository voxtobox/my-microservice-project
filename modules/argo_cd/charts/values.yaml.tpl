applications:
  - name: example-app
    namespace: default
    project: default
    source:
      repoURL: ${app_repo_url}
      path: django-chart
      targetRevision: main
      helm:
        valueFiles:
          - values.yaml
    destination:
      server: https://kubernetes.default.svc
      namespace: default
    syncPolicy:
      automated:
        prune: true
        selfHeal: true

repositories:
  - name: example-app
    url: ${app_repo_url}
    username: ${app_repo_username}
    password: ${app_repo_password}
    repoConfig:
      insecure: "true"
      enableLfs: "true"


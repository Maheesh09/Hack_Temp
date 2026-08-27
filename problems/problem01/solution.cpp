#include <bits/stdc++.h>
using namespace std;

using ll = long long;

ll mergeAndCount(vector<int>& a, vector<int>& temp, int left, int right) {
    if (left >= right) {
        return 0;
    }

    int mid = left + (right - left) / 2;

    ll inversions = 0;

    inversions += mergeAndCount(a, temp, left, mid);
    inversions += mergeAndCount(a, temp, mid + 1, right);

    int i = left;
    int j = mid + 1;
    int k = left;

    while (i <= mid && j <= right) {

        if (a[i] <= a[j]) {
            temp[k++] = a[i++];
        }
        else {
            temp[k++] = a[j++];

            inversions += mid - i + 1;
        }
    }

    while (i <= mid) {
        temp[k++] = a[i++];
    }

    while (j <= right) {
        temp[k++] = a[j++];
    }

    for (int p = left; p <= right; ++p) {
        a[p] = temp[p];
    }

    return inversions;
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    cin >> n;

    vector<int> a(n);
    vector<int> temp(n);

    for (int& x : a) {
        cin >> x;
    }

    cout << mergeAndCount(a, temp, 0, n - 1) << '\n';

    return 0;
}
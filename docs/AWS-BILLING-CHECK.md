# 💰 AWS Billing & Resource Check Guide

## 🎯 Quick Checklist

### 1. Check Your Bill
- **Go to**: AWS Console → Billing Dashboard
- **Check**: Month-to-date charges
- **Target**: $0.00 if everything is deleted

### 2. EC2 Instances
- **Location**: EC2 → Instances
- **Status to check**:
  - ✅ 0 running instances = Good
  - ✅ 0 stopped instances = Good
  - ✅ All terminated = Good

### 3. RDS Databases
- **Location**: RDS → Databases
- **Status to check**:
  - ✅ "No databases" = Good
  - ❌ Any "Available" = Charging you

### 4. S3 Buckets
- **Location**: S3 → Buckets
- **Status to check**:
  - ✅ No buckets = Good
  - ⚠️ Empty buckets = Very small charge

### 5. Elastic IPs
- **Location**: EC2 → Elastic IPs (in left menu)
- **Status to check**:
  - ✅ "No Elastic IPs" = Good
  - ❌ Any unattached IPs = $3.60/month

### 6. Load Balancers
- **Location**: EC2 → Load Balancers
- **Status to check**:
  - ✅ No load balancers = Good
  - ❌ Any load balancers = $18/month

### 7. CloudFront Distributions
- **Location**: CloudFront → Distributions
- **Status to check**:
  - ✅ No distributions = Good
  - ⚠️ Disabled distributions = Small charge

### 8. NAT Gateways
- **Location**: VPC → NAT Gateways
- **Status to check**:
  - ✅ No NAT Gateways = Good
  - ❌ Any NAT Gateways = $33/month

### 9. Volumes (EBS)
- **Location**: EC2 → Volumes
- **Status to check**:
  - ✅ All "in-use" or "deleted" = Good
  - ⚠️ "available" volumes = $0.10/GB/month

### 10. Snapshots
- **Location**: EC2 → Snapshots
- **Status to check**:
  - ✅ No snapshots = Good
  - ⚠️ Any snapshots = $0.05/GB/month

## 💡 **Top Services That Cost Money**

1. **RDS Database** - $15-20/month (most expensive)
2. **EC2 Instance** - $8-10/month
3. **Load Balancers** - $18/month
4. **NAT Gateway** - $33/month
5. **Elastic IP (unattached)** - $3.60/month
6. **S3 Storage** - $0.023/GB/month (cheap)
7. **CloudFront** - Pay per use (usually cheap)

## 🚨 **How to Get $0 Bill**

Delete in this order:

1. ✅ **Terminate EC2 instances**
2. ✅ **Delete RDS databases**
3. ✅ **Delete NAT Gateways** (if any)
4. ✅ **Delete Load Balancers** (if any)
5. ✅ **Release Elastic IPs**
6. ✅ **Delete CloudFront distributions**
7. ✅ **Empty and delete S3 buckets**
8. ✅ **Delete EBS volumes** (if any unattached)
9. ✅ **Delete snapshots** (if any)

## 📊 **Expected Bill Timeline**

- **Immediate**: Resource stops charging when deleted
- **24 hours**: Billing dashboard updates
- **48 hours**: Should see $0.00 if everything deleted

## 🔔 **Set Up Billing Alert**

1. Billing Dashboard → Billing preferences
2. Enable "Receive Billing Alerts"
3. CloudWatch → Create Alarm
4. Set threshold: $1
5. Get email when you exceed $1

## ✅ **Verification Checklist**

After deleting everything:

- [ ] Billing Dashboard shows $0.00
- [ ] EC2: 0 running instances
- [ ] RDS: No databases
- [ ] S3: No buckets (or empty buckets)
- [ ] Elastic IPs: None allocated
- [ ] Load Balancers: None
- [ ] CloudFront: No distributions
- [ ] NAT Gateways: None
- [ ] EBS Volumes: Only "in-use" ones
- [ ] Snapshots: None

## 🎯 **Your Task Manager Resources**

Specifically for your Task Manager:

- **EC2**: `task-manager-backend` instance
- **RDS**: `task-manager-prod` database
- **S3**: `task-manager-frontend-prakshal` bucket
- **Elastic IP**: Check if you have one

**Delete all of these to stop charges!**

---

**Check billing dashboard 24 hours after deletion to confirm $0 charges!** 💰
